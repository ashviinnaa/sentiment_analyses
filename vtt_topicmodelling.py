
import webvtt
import re
import pandas as pd
from bertopic import BERTopic
import sys
import os

def load_and_clean_transcript(vtt_file_path):
    transcript_text = ""
    for caption in webvtt.read(vtt_file_path):
        transcript_text += caption.text + " "

    # Clean and normalize spaces
    clean_text = re.sub(r'\s+', ' ', transcript_text).strip()

    # Split into sentences
    sentences = re.split(r'(?<=[.!?])\s+', clean_text)
    sentences = [sentence.strip() for sentence in sentences if sentence.strip()]
    
    return sentences


def thematic_analysis(sentences):
    topic_model = BERTopic()
    topics, _ = topic_model.fit_transform(sentences)
    return topic_model, topics


def save_results(sentences, topics, output_path):
    df = pd.DataFrame({"sentence": sentences, "topic": topics})
    df.to_csv(output_path, index=False)


def main(vtt_file_path, output_csv_path):
    sentences = load_and_clean_transcript(vtt_file_path)
    topic_model, topics = thematic_analysis(sentences)
    save_results(sentences, topics, output_csv_path)
    
    # Display topics briefly
    for topic_id, topic_words in topic_model.get_topics().items():
        print(f"Topic {topic_id}: {topic_words}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python thematic_analysis.py <path_to_vtt_file> <output_csv_path>")
        sys.exit(1)

    vtt_file_path = sys.argv[1]
    output_csv_path = sys.argv[2]

    if not os.path.exists(vtt_file_path):
        print(f"Error: File '{vtt_file_path}' not found.")
        sys.exit(1)

    main(vtt_file_path, output_csv_path)
