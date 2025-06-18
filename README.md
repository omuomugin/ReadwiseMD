# ReadwiseMD

Script to generate markdown files from Readwise favorite articles.  
This script creates a summary of your favorite items and archives the original content as markdown files.

Designed for use with Obsidian and other markdown-based note-taking applications.

## Requirements

### Install Dependencies

```shell
# JSON processing tool
brew install jq

# Web content extraction tool for creating archives
brew install trafilatura
```

### Get Readwise API Token

1. Visit https://readwise.io/
2. Go to your account settings
3. Generate an API access token

### Setup Configuration

Copy the environment template and configure your paths:

```shell
cp script/.env.example script/.env
```

Edit `script/.env` with your settings:

| Variable | Description |
|----------|-------------|
| `READWISE_ACCESS_TOKEN` | Your Readwise API token |
| `FAVORITE_ITEMS_JSON_PATH` | Path to cache API responses (e.g., `./bin/favorite_articles.json`) |
| `OUTPUT_FAVORITE_ITEM_LIST_FILE_PATH` | Output path for summary markdown |
| `OUTPUT_FAVORITE_ITEM_ARCHIVE_DIR` | Directory for archived article files |
| `RESOLVED_ITEM_JSON_PATH` | Path to tracking file (e.g., `./bin/resolved.json`) |
| `FRONT_MATTER` | Optional front matter for generated markdown files |

### Create Tracking File

Copy the resolved items template:

```shell
cp script/resolved_item.example.json /path/to/your/resolved.json
```

## Usage

Run the complete pipeline:

```shell
cd script
sh run.sh
```

This will:
1. Fetch favorite articles from Readwise API
2. Generate a chronological summary markdown file
3. Create individual markdown archives for unresolved articles
4. Update the tracking file to prevent reprocessing

## Output Structure

- **Summary file**: Chronologically organized list with links to archived articles
- **Archive directory**: Individual markdown files for each article
- **Tracking file**: JSON file maintaining processing state for incremental runs

## Notes

- Article titles containing `/` and `:` are converted to `-` for filesystem compatibility
- Articles with URL-only titles become "title-unresolved" in filenames
- Archive files are named `{title}-{item_id}.md` to ensure uniqueness
- The script processes only new/unresolved items on subsequent runs