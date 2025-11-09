#!/usr/bin/env python3
"""
bilingual_srt_improved.py

改进版双语字幕翻译脚本，解决批量翻译时的格式问题。
使用逐行翻译策略，确保每行都有对应的翻译。
"""
import argparse
import re
import sys
import os
import time
from typing import List

CHINESE_RE = re.compile(r'[\u4e00-\u9fff]')


def read_file(path: str) -> str:
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        return f.read()


def write_file(path: str, content: str) -> None:
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def parse_srt(content: str):
    raw_blocks = re.split(r"\r?\n\s*\r?\n", content.strip())
    blocks = []
    for blk in raw_blocks:
        lines = blk.splitlines()
        if not lines:
            continue
        if len(lines) >= 2 and '-->' in lines[1]:
            index = lines[0].strip()
            times = lines[1].strip()
            text = "\n".join(l.rstrip() for l in lines[2:]).strip()
        else:
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
    逐行翻译单个文本，确保每行都有对应的翻译
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
            temperature=0.1,  # 降低随机性
            max_tokens=100
        )
        
        result = response.choices[0].message.content.strip()
        
        # 清理结果：移除可能的序号和多余内容
        result = re.sub(r'^\d+[\.\s]*', '', result)  # 移除开头数字和点
        result = re.sub(r'^[\"\']|[\"\']$', '', result)  # 移除引号
        result = result.strip()
        
        # 如果结果为空或与原文相同，返回空字符串
        if not result or result == text:
            return ""
            
        return result
        
    except Exception as e:
        print(f"翻译失败: {text[:50]}... - {e}")
        return ""


def batch_translate_improved(texts: List[str], api_key: str, base_url: str = "https://api.deepseek.com", model: str = "deepseek-chat") -> List[str]:
    """
    改进的批量翻译：逐行翻译，避免批量处理时的格式问题
    """
    translated = []
    
    for i, text in enumerate(texts):
        print(f"翻译进度: {i+1}/{len(texts)}", end='\r')
        
        # 逐行翻译
        translation = translate_single_line(text, api_key, base_url, model)
        translated.append(translation)
        
        # 添加延迟避免请求过快
        time.sleep(0.5)
    
    print()  # 换行
    return translated


def main():
    parser = argparse.ArgumentParser(description='Improved bilingual SRT translator')
    parser.add_argument('input', help='input .srt file')
    parser.add_argument('output', help='output .srt file')
    parser.add_argument('--deepseek-key', help='Deepseek API key')
    parser.add_argument('--deepseek-url', default='https://api.deepseek.com', help='Deepseek API base URL')
    parser.add_argument('--deepseek-model', default='deepseek-chat', help='Deepseek model name')
    
    args = parser.parse_args()

    if not args.deepseek_key:
        args.deepseek_key = os.environ.get('DEEPSEEK_API_KEY')
        if not args.deepseek_key:
            print("错误: 请设置 DEEPSEEK_API_KEY 环境变量或提供 --deepseek-key 参数")
            sys.exit(1)

    content = read_file(args.input)
    blocks = parse_srt(content)

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

    out = build_srt(blocks)
    write_file(args.output, out)
    print(f'已写出: {args.output}')


if __name__ == '__main__':
    main()