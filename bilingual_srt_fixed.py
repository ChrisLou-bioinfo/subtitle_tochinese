#!/usr/bin/env python3
"""
bilingual_srt_fixed.py

将英文 SRT 翻译为中英双语 SRT（时间轴与序号保持不变，正文为：英文原文\n中文翻译）。
使用 Deepseek API（兼容 OpenAI SDK）。

用法:
  export DEEPSEEK_API_KEY=your_api_key
  python bilingual_srt_fixed.py input.srt output.srt

可选参数 --provider 指定翻译提供者（默认 deepseek）。
"""
import argparse
import re
import sys
import os
from typing import List

CHINESE_RE = re.compile(r'[\u4e00-\u9fff]')


def read_file(path: str) -> str:
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        return f.read()


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


def batch_translate_deepseek(texts: List[str], api_key: str, base_url: str = "https://api.deepseek.com", model: str = "deepseek-chat") -> List[str]:
    """
    使用 Deepseek API（兼容 OpenAI SDK）批量翻译文本
    """
    try:
        from openai import OpenAI
    except ImportError:
        raise ImportError("请先安装 OpenAI SDK: pip install openai")

    client = OpenAI(
        api_key=api_key,
        base_url=base_url
    )

    # 构建翻译提示 - 更严格的格式要求
    system_prompt = """你是一个专业的字幕翻译助手。请将提供的英文文本逐行翻译成简体中文。
重要：请严格按照以下格式返回：
1. 第一行翻译
2. 第二行翻译
3. 第三行翻译
...

不要添加任何额外的解释、序号外的文字或标记。确保翻译准确、流畅，保持专业术语的一致性。"""

    translated = []
    
    # 分批处理，避免请求过大 - 减少批量大小以提高准确性
    batch_size = 5
    for i in range(0, len(texts), batch_size):
        batch_texts = texts[i:i+batch_size]
        
        # 构建用户消息 - 更清晰的格式
        user_content = "请逐行翻译以下英文文本：\n"
        for j, text in enumerate(batch_texts):
            user_content += f"行 {j+1}: {text}\n"
        
        try:
            response = client.chat.completions.create(
                model=model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_content}
                ],
                temperature=0.3,
                max_tokens=2000
            )
            
            result = response.choices[0].message.content
            
            # 解析返回结果 - 更严格的解析逻辑
            lines = []
            for line in result.split('\n'):
                line = line.strip()
                if not line:
                    continue
                # 移除序号和点（支持多种格式）
                if re.match(r'^\d+\.\s*', line):
                    line = re.sub(r'^\d+\.\s*', '', line)
                elif re.match(r'^\d+\s*', line):
                    line = re.sub(r'^\d+\s*', '', line)
                elif '行 ' in line:
                    line = re.sub(r'^行\s*\d+\s*:\s*', '', line)
                lines.append(line)
            
            # 使用解析后的行
            batch_translations = lines
            
            # 确保返回数量匹配 - 更严格的检查
            if len(batch_translations) >= len(batch_texts):
                translated.extend(batch_translations[:len(batch_texts)])
            else:
                # 如果数量不足，填充空字符串
                translated.extend(batch_translations)
                translated.extend([''] * (len(batch_texts) - len(batch_translations)))
                
        except Exception as e:
            print(f"翻译批次 {i//batch_size + 1} 失败: {e}")
            # 失败时返回空字符串
            translated.extend([''] * len(batch_texts))
    
    return translated


def batch_translate(texts: List[str], provider: str = "deepseek", api_key: str = None, base_url: str = None) -> List[str]:
    """
    批量翻译文本
    """
    if provider == "deepseek":
        if not api_key:
            api_key = os.environ.get('DEEPSEEK_API_KEY')
            if not api_key:
                raise ValueError("请设置 DEEPSEEK_API_KEY 环境变量或提供 --deepseek-key 参数")
        
        if not base_url:
            base_url = "https://api.deepseek.com"
            
        return batch_translate_deepseek(texts, api_key, base_url)
    
    else:
        raise ValueError(f"不支持的翻译提供者: {provider}")


def main():
    parser = argparse.ArgumentParser(description='Translate English SRT to bilingual (EN+ZH) SRT')
    parser.add_argument('input', help='input .srt file')
    parser.add_argument('output', help='output .srt file')
    parser.add_argument('--provider', choices=['deepseek'], default='deepseek', help='translation provider (default: deepseek)')
    parser.add_argument('--deepseek-key', help='Deepseek API key (optional, uses DEEPSEEK_API_KEY env var by default)')
    parser.add_argument('--deepseek-url', default='https://api.deepseek.com', help='Deepseek API base URL (default: https://api.deepseek.com)')
    parser.add_argument('--deepseek-model', default='deepseek-chat', help='Deepseek model name (default: deepseek-chat)')
    
    args = parser.parse_args()

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
        print(f"待翻译段落: {len(texts_to_translate)}，使用 {args.provider} 翻译...")
        try:
            zh_list = batch_translate(
                texts_to_translate, 
                provider=args.provider,
                api_key=args.deepseek_key,
                base_url=args.deepseek_url
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