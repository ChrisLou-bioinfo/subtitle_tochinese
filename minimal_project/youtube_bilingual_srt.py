#!/usr/bin/env python3
"""
YouTube双语字幕生成模块
简洁版本 - 专为GitHub发布优化
"""
import json
import time
import requests
from typing import List, Dict, Any


def parse_srt(content: str) -> List[Dict[str, Any]]:
    """解析SRT字幕文件"""
    blocks = []
    lines = content.strip().split('\n')
    i = 0
    
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
            
        try:
            # 序号
            num = int(line)
            i += 1
            
            # 时间轴
            if i < len(lines):
                timeline = lines[i].strip()
                i += 1
            else:
                break
                
            # 字幕文本
            text_lines = []
            while i < len(lines) and lines[i].strip():
                text_lines.append(lines[i].strip())
                i += 1
                
            text = ' '.join(text_lines)
            
            # 解析时间
            if ' --> ' in timeline:
                start_time, end_time = timeline.split(' --> ')
                blocks.append({
                    'num': num,
                    'start': start_time.strip(),
                    'end': end_time.strip(),
                    'text': text
                })
                
        except ValueError:
            i += 1
            
    return blocks


def build_srt(blocks: List[Dict[str, Any]]) -> str:
    """构建SRT字幕内容"""
    content = []
    for i, block in enumerate(blocks):
        content.append(str(i + 1))
        content.append(f"{block['start']} --> {block['end']}")
        
        # 英文原文
        if block.get('text'):
            content.append(block['text'])
        
        # 中文翻译
        if block.get('zh'):
            content.append(block['zh'])
        
        content.append('')
    
    return '\n'.join(content)


def batch_translate_improved(texts: List[str], api_key: str) -> List[str]:
    """批量翻译文本"""
    if not texts:
        return []
    
    # Deepseek API配置
    url = "https://api.deepseek.com/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    zh_list = []
    batch_size = 5  # 小批量处理避免超时
    
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        
        # 构建翻译提示
        prompt = "请将以下英文句子翻译成中文，保持简洁准确：\n"
        for j, text in enumerate(batch):
            prompt += f"{j+1}. {text}\n"
        
        data = {
            "model": "deepseek-chat",
            "messages": [
                {"role": "system", "content": "你是一个专业的翻译助手，负责将英文翻译成简洁准确的中文。"},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.3,
            "max_tokens": 2000
        }
        
        try:
            response = requests.post(url, headers=headers, json=data, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            translated_text = result['choices'][0]['message']['content']
            
            # 解析翻译结果
            lines = translated_text.strip().split('\n')
            batch_translations = []
            
            for line in lines:
                line = line.strip()
                if line and (line[0].isdigit() or '.' in line):
                    # 移除序号
                    parts = line.split('.', 1)
                    if len(parts) > 1:
                        translation = parts[1].strip()
                        batch_translations.append(translation)
                    else:
                        batch_translations.append(line)
                elif line:
                    batch_translations.append(line)
            
            # 确保数量匹配
            if len(batch_translations) == len(batch):
                zh_list.extend(batch_translations)
            else:
                # 如果解析失败，使用原始文本作为占位符
                zh_list.extend(["翻译失败"] * len(batch))
            
            print(f"翻译进度: {min(i + len(batch), len(texts))}/{len(texts)}")
            time.sleep(1)  # 避免API限制
            
        except Exception as e:
            print(f"翻译批次 {i//batch_size + 1} 失败: {e}")
            zh_list.extend(["翻译失败"] * len(batch))
    
    return zh_list


# 测试代码
if __name__ == '__main__':
    # 测试SRT解析
    test_srt = """1
00:00:01,000 --> 00:00:04,000
Hello world

2
00:00:05,000 --> 00:00:08,000
This is a test
"""
    
    blocks = parse_srt(test_srt)
    print("解析结果:")
    for block in blocks:
        print(f"{block['start']} --> {block['end']}: {block['text']}")
    
    # 测试构建
    rebuilt = build_srt(blocks)
    print("\n重建的SRT:")
    print(rebuilt)