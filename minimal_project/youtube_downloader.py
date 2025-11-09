#!/usr/bin/env python3
"""
YouTube视频下载与双语字幕合并工具
简洁版本 - 专为GitHub发布优化
"""
import argparse
import os
import sys
import subprocess
import tempfile
import shutil
from pathlib import Path


def download_youtube_video(url: str, output_folder: str) -> dict:
    """下载YouTube视频"""
    try:
        import yt_dlp
    except ImportError:
        print("错误: 请先安装 yt-dlp: pip install yt-dlp")
        return None
    
    os.makedirs(output_folder, exist_ok=True)
    
    ydl_opts = {
        'format': 'bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best[ext=mp4]',
        'outtmpl': os.path.join(output_folder, '%(title)s.%(ext)s'),
        'writesubtitles': True,
        'writeautomaticsub': True,
        'subtitleslangs': ['en'],
        'subtitlesformat': 'srt',
        'quiet': False,
    }
    
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            
        result = {
            'title': info.get('title', 'unknown'),
            'video_file': None,
            'subtitle_file': None,
            'info': info
        }
        
        # 查找视频文件
        video_title = info.get('title', 'unknown')
        for file in os.listdir(output_folder):
            if file.startswith(video_title) and (file.endswith('.mp4') or file.endswith('.m4a') or file.endswith('.webm')):
                result['video_file'] = os.path.join(output_folder, file)
                break
        
        # 查找字幕文件
        for file in os.listdir(output_folder):
            if file.startswith(video_title) and file.endswith('.srt'):
                result['subtitle_file'] = os.path.join(output_folder, file)
                break
                
        return result
        
    except Exception as e:
        print(f"下载视频失败: {e}")
        return None


def translate_subtitles(subtitle_file: str, api_key: str, output_folder: str) -> str:
    """翻译字幕文件"""
    try:
        sys.path.append(os.path.dirname(__file__))
        from youtube_bilingual_srt import parse_srt, build_srt, batch_translate_improved
        
        with open(subtitle_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        blocks = parse_srt(content)
        
        texts_to_translate = []
        map_idx = []
        for idx, b in enumerate(blocks):
            text = b.get('text', '')
            if text and not any(c in '\u4e00-\u9fff' for c in text):
                texts_to_translate.append(text)
                map_idx.append(idx)
        
        if texts_to_translate:
            print(f"翻译字幕段落: {len(texts_to_translate)}")
            zh_list = batch_translate_improved(texts_to_translate, api_key)
            for i, zh in zip(map_idx, zh_list):
                blocks[i]['zh'] = zh
        
        bilingual_content = build_srt(blocks)
        
        base_name = os.path.splitext(os.path.basename(subtitle_file))[0]
        bilingual_file = os.path.join(output_folder, f"{base_name}_bilingual.srt")
        
        with open(bilingual_file, 'w', encoding='utf-8') as f:
            f.write(bilingual_content)
        
        return bilingual_file
        
    except Exception as e:
        print(f"翻译字幕失败: {e}")
        return None


def merge_subtitle_to_video(video_file: str, subtitle_file: str, output_folder: str) -> str:
    """使用ffmpeg将字幕烧录到视频中"""
    try:
        subprocess.run(['ffmpeg', '-version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("错误: 请先安装ffmpeg")
        return None
    
    base_name = os.path.splitext(os.path.basename(video_file))[0]
    if base_name.endswith('.mp4'):
        base_name = base_name[:-4]
    output_file = os.path.join(output_folder, f"{base_name}_with_subtitles.mp4")
    
    cmd = [
        'ffmpeg',
        '-i', video_file,
        '-vf', f"subtitles={subtitle_file}:force_style='FontName=Helvetica,FontSize=11,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BackColour=&H80000000,BorderStyle=3,Outline=1,Shadow=0,MarginV=10'",
        '-c:v', 'libx264',
        '-preset', 'medium',
        '-crf', '23',
        '-profile:v', 'high',
        '-level', '4.0',
        '-c:a', 'aac',
        '-b:a', '128k',
        '-movflags', '+faststart',
        output_file,
        '-y'
    ]
    
    try:
        print("正在合并字幕到视频...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"视频合并成功: {output_file}")
            return output_file
        else:
            print(f"合并失败: {result.stderr}")
            return None
            
    except Exception as e:
        print(f"合并过程出错: {e}")
        return None


def load_env_file():
    """加载.env配置文件"""
    env_file = os.path.join(os.path.dirname(__file__), '.env')
    if os.path.exists(env_file):
        try:
            with open(env_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        key, value = line.split('=', 1)
                        os.environ[key.strip()] = value.strip()
        except Exception as e:
            print(f"警告: 读取.env文件失败: {e}")


def main():
    parser = argparse.ArgumentParser(description='YouTube视频下载与双语字幕合并')
    parser.add_argument('youtube_url', help='YouTube视频链接')
    parser.add_argument('output_folder', help='输出文件夹路径')
    parser.add_argument('--deepseek-key', help='Deepseek API key')
    
    args = parser.parse_args()

    load_env_file()
    
    if not args.deepseek_key:
        args.deepseek_key = os.environ.get('DEEPSEEK_API_KEY')
        if not args.deepseek_key:
            print("错误: 请设置 DEEPSEEK_API_KEY 环境变量或提供 --deepseek-key 参数")
            sys.exit(1)

    print("=" * 50)
    print("YouTube视频下载与双语字幕合并工具")
    print("=" * 50)
    
    # 检查是否已有完整的视频和双语字幕
    video_title = None
    existing_files = {}
    
    if os.path.exists(args.output_folder):
        for file in os.listdir(args.output_folder):
            if file.endswith('.mp4') and '_with_subtitles' not in file:
                video_title = file.replace('.mp4', '')
                existing_files['video'] = os.path.join(args.output_folder, file)
            elif file.endswith('_bilingual.srt'):
                existing_files['bilingual_subtitle'] = os.path.join(args.output_folder, file)
            elif file.endswith('.en.srt') and '_bilingual' not in file:
                existing_files['original_subtitle'] = os.path.join(args.output_folder, file)
    
    # 步骤1: 下载视频和字幕（如果不存在）
    print(f"\n步骤1: 检查并下载视频和字幕")
    print(f"链接: {args.youtube_url}")
    print(f"输出文件夹: {args.output_folder}")
    
    if existing_files.get('video') and existing_files.get('bilingual_subtitle'):
        print("✓ 发现已存在的视频和双语字幕，跳过下载")
        download_result = {
            'title': video_title,
            'video_file': existing_files['video'],
            'subtitle_file': existing_files['original_subtitle'] if existing_files.get('original_subtitle') else existing_files['bilingual_subtitle']
        }
    else:
        download_result = download_youtube_video(args.youtube_url, args.output_folder)
        
        if not download_result:
            print("下载失败")
            sys.exit(1)
    
    print(f"✓ 视频标题: {download_result['title']}")
    print(f"✓ 视频文件: {download_result['video_file']}")
    print(f"✓ 字幕文件: {download_result['subtitle_file']}")
    
    # 步骤2: 翻译字幕（如果跳过下载且已有双语字幕，则跳过翻译）
    print(f"\n步骤2: 翻译字幕")
    
    if existing_files.get('bilingual_subtitle') and existing_files.get('video'):
        print("✓ 使用已存在的双语字幕，跳过翻译")
        bilingual_subtitle = existing_files['bilingual_subtitle']
    elif download_result['subtitle_file']:
        bilingual_subtitle = translate_subtitles(
            download_result['subtitle_file'], 
            args.deepseek_key, 
            args.output_folder
        )
        
        if bilingual_subtitle:
            print(f"✓ 双语字幕: {bilingual_subtitle}")
        else:
            print("✗ 字幕翻译失败")
    else:
        print("✗ 未找到字幕文件")
        bilingual_subtitle = None
    
    # 步骤3: 合并字幕到视频
    print(f"\n步骤3: 合并字幕到视频")
    
    if bilingual_subtitle and download_result['video_file']:
        merged_video = merge_subtitle_to_video(
            download_result['video_file'], 
            bilingual_subtitle, 
            args.output_folder
        )
        
        if merged_video:
            print(f"✓ 合并视频: {merged_video}")
        else:
            print("✗ 视频合并失败")
    else:
        print("✗ 缺少视频或字幕文件，跳过合并")
    
    # 步骤4: 总结
    print(f"\n步骤4: 完成")
    print("-" * 40)
    print("生成的文件:")
    
    for file in os.listdir(args.output_folder):
        file_path = os.path.join(args.output_folder, file)
        size = os.path.getsize(file_path) / (1024 * 1024)  # MB
        print(f"  {file} ({size:.1f} MB)")
    
    print("\n✓ 所有操作完成！")


if __name__ == '__main__':
    main()