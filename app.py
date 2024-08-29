from flask import Flask, request, jsonify
import requests
import bs4
import re

app = Flask(__name__)

def extract_video_url_from_twitter(tweet_url):
    """Extract the highest quality video URL from a Twitter post URL using twitsave.com.

    Args:
        tweet_url (str): The Twitter post URL to extract the video from.

    Returns:
        str: The highest quality video URL.
    """

    try:
        # Use twitsave.com to get video info
        api_url = f"https://twitsave.com/info?url={tweet_url}"
        response = requests.get(api_url)
        response.raise_for_status()  # Raise an exception for HTTP errors
        
        # Parse the HTML content
        data = bs4.BeautifulSoup(response.text, 'html.parser')
        
        # Find download button and extract the highest quality video URL
        download_button = data.find_all("div", class_="origin-top-right")[0]
        quality_buttons = download_button.find_all("a")
        highest_quality_url = quality_buttons[0].get("href")  # Highest quality video URL
        
        return highest_quality_url

    except Exception as e:
        raise Exception(f"Failed to extract video URL: {e}")

@app.route('/extract-video', methods=['POST'])
def extract_video():
    tweet_url = request.json.get('tweet_url')
    if tweet_url:
        try:
            video_url = extract_video_url_from_twitter(tweet_url)
            if video_url:
                return jsonify({"status": "success", "video_url": video_url}), 200
            else:
                return jsonify({"status": "error", "message": "No video found in tweet"}), 404
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500
    else:
        return jsonify({"status": "error", "message": "Invalid request: tweet_url not provided"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9000, debug=False)
