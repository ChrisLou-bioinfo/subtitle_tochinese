#!/usr/bin/env python3
"""
youtube_bilingual_srt.py

集成 YouTube 字幕下载与双语翻译功能。
输入 YouTube 链接，自动下载字幕并翻译成中英双语。

用法:
  export DEEPSEEK_API_KEY=your_api_key
  python youtube_bilingual_srt.py "youtube_url" output.srt

依赖:
  pip install yt-dlp openai
"""
import argparse
import re
import sys
import os
import time
import subprocess
import tempfile
from typing import List, Optional

CHINESE_RE = re.compile(r'[\u4e00-\u9fff]')


def download_youtube_subtitles(url: str, language: str = 'en') -> Optional[str]:
    """
    使用 yt-dlp 下载 YouTube 字幕
    返回字幕文件内容或 None
    """
    try:
        import yt_dlp
    except ImportError:
        print("错误: 请先安装 yt-dlp: pip install yt-dlp")
        return None
    
    # 创建临时目录
    with tempfile.TemporaryDirectory() as temp_dir:
        ydl_opts = {
            'writesubtitles': True,
            'writeautomaticsub': True,
            'subtitleslangs': [language],
            'subtitlesformat': 'srt',
            'skip_download': True,
            'outtmpl': os.path.join(temp_dir, '%(title)s.%(ext)s'),
            'quiet': True,
        }
        
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
                
            # 查找下载的字幕文件
            for file in os.listdir(temp_dir):
                if file.endswith('.srt'):
                    srt_path = os.path.join(temp_dir, file)
                    with open(srt_path, 'r', encoding='utf-8') as f:
                        return f.read()
                        
            # 如果没有找到字幕文件，尝试自动生成的字幕
            ydl_opts_auto = {
                'writeautomaticsub': True,
                'subtitlesformat': 'srt',
                'skip_download': True,
                'outtmpl': os.path.join(temp_dir, 'auto_%(title)s.%(ext)s'),
                'quiet': True,
            }
            
            with yt_dlp.YoutubeDL(ydl_opts_auto) as ydl:
                ydl.download([url])
                
            for file in os.listdir(temp_dir):
                if file.endswith('.srt'):
                    srt_path = os.path.join(temp_dir, file)
                    with open(srt_path, 'r', encoding='utf-8') as f:
                        return f.read()
                        
        except Exception as e:
            print(f"下载字幕失败: {e}")
            return None
    
    return None


def write_file(path: str, content: str) -> None:
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def parse_srt(content: str):
    # 按空行分块，兼容 CRLF/LF
    raw_blocks = re.split(r"\r?\n\s*\r?\n", content.strip())
    blocks = []
    for blk in raw_blocks:
        lines = blk.splitlines()
        if not lines:
            continue
        # 寻找时间行（通常包含 -->）
        if len(lines) >= 2 and '-->' in lines[1]:
            index = lines[0].strip()
            times = lines[1].strip()
            text = "\n".join(l.rstrip() for l in lines[2:]).strip()
        else:
            # 如果没有序号行，尝试容错解析
            index = ''
            times = lines[0].strip() if '-->' in lines[0] else ''
            text = "\n".join(lines[1:]).strip()
        blocks.append({'index': index, 'times': times, 'text': text})
    return blocks


def build_srt(blocks) -> str:
    out_blocks = []
    for i, b in enumerate(blocks, start=1):
        idx = b.get('index') or str(i)
        times = b.get('times', '')
        zh = b.get('zh', '').strip()
        en = b.get('text', '').strip()
        if zh:
            combined = en + '\n' + zh
        else:
            combined = en
        out_blocks.append(f"{idx}\n{times}\n{combined}")
    return "\n\n".join(out_blocks) + "\n"


def translate_single_line(text: str, api_key: str, base_url: str = "https://api.deepseek.com", model: str = "deepseek-chat") -> str:
    """
    逐行翻译单个文本
    """
    try:
        from openai import OpenAI
    except ImportError:
        raise ImportError("请先安装 OpenAI SDK: pip install openai")

    client = OpenAI(api_key=api_key, base_url=base_url)

    system_prompt = """你是一个专业的字幕翻译助手。请将英文文本准确翻译成简体中文。
只返回翻译后的中文文本，不要添加任何序号、解释或额外文字。"""

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"请翻译：{text}"}
            ],
            temperature=0.1,
            max_tokens=100
        )
        
        result = response.choices[0].message.content.strip()
        
        # 清理结果
        result = re.sub(r'^\d+[\.\s]*', '', result)
        result = re.sub(r'^[\"\']|[\"\']$', '', result)
        result = result.strip()
        
        if not result or result == text:
            return ""
            
        return result
        
    except Exception as e:
        print(f"翻译失败: {text[:50]}... - {e}")
        return ""


def batch_translate_improved(texts: List[str], api_key: str, base_url: str = "https://api.deepseek.com", model: str = "deepseek-chat") -> List[str]:
    """
    改进的批量翻译：逐行翻译
    """
    translated = []
    
    for i, text in enumerate(texts):
        print(f"翻译进度: {i+1}/{len(texts)}", end='\r')
        
        translation = translate_single_line(text, api_key, base_url, model)
        translated.append(translation)
        
        # 添加延迟避免请求过快
        time.sleep(0.5)
    
    print()
    return translated


def main():
    parser = argparse.ArgumentParser(description='YouTube双语字幕生成器')
    parser.add_argument('youtube_url', help='YouTube视频链接')
    parser.add_argument('output', help='输出双语字幕文件路径')
    parser.add_argument('--language', default='en', help='字幕语言代码 (默认: en)')
    parser.add_argument('--deepseek-key', help='Deepseek API key')
    parser.add_argument('--deepseek-url', default='https://api.deepseek.com', help='Deepseek API base URL')
    parser.add_argument('--deepseek-model', default='deepseek-chat', help='Deepseek model name')
    
    args = parser.parse_args()

    if not args.deepseek_key:
        args.deepseek_key = os.environ.get('DEEPSEEK_API_KEY')
        if not args.deepseek_key:
            print("错误: 请设置 DEEPSEEK_API_KEY 环境变量或提供 --deepseek-key 参数")
            sys.exit(1)

    # 步骤1: 下载YouTube字幕
    print(f"正在下载 YouTube 字幕: {args.youtube_url}")
    subtitle_content = download_youtube_subtitles(args.youtube_url, args.language)
    
    if not subtitle_content:
        print("错误: 无法下载字幕，请检查链接和网络连接")
        sys.exit(1)
    
    print("字幕下载成功")
    
    # 步骤2: 解析字幕
    blocks = parse_srt(subtitle_content)
    
    # 步骤3: 翻译字幕
    texts_to_translate = []
    map_idx = []
    for idx, b in enumerate(blocks):
        text = b.get('text', '')
        if not text or CHINESE_RE.search(text):
            b['zh'] = ''
            continue
        texts_to_translate.append(text)
        map_idx.append(idx)

    if texts_to_translate:
        print(f"待翻译段落: {len(texts_to_translate)}，使用逐行翻译...")
        try:
            zh_list = batch_translate_improved(
                texts_to_translate, 
                api_key=args.deepseek_key,
                base_url=args.deepseek_url,
                model=args.deepseek_model
            )
            for i, zh in zip(map_idx, zh_list):
                blocks[i]['zh'] = zh
        except Exception as e:
            print(f"翻译失败: {e}")
            sys.exit(1)
    else:
        print('没有需要翻译的段落。')

    # 步骤4: 生成双语字幕
    out = build_srt(blocks)
    write_file(args.output, out)
    print(f'双语字幕已生成: {args.output}')


if __name__ == '__main__':
    main()