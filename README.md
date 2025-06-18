# PocketMD
Script to generate markdown files from Pocket favorite items.  
This script will create a summary of your favorite items and archive the original content.  

It is intended to be used for Obsidian or such markdown note-taking apps.

## Requirements
### Install the following dependencies

```shell
# see also https://github.com/jqlang/jq
brew install jq

# for creating archive 
# see also https://github.com/adbar/trafilatura
brew install trafilatura
```

### Get Pocket consumer key
https://getpocket.com/developer/apps/new

### Copy `resolved.example.json`
copy `resolved.example.json` as `resolved.json` to where you want to save summary and archive.

e.g. 

```txt
.
├── bin
│   └── pocket
│       ├── archive # for archive files
│       └── resolved.json
└── scraps
    └── favorite_item_summary.md
```


### Copy `.env.example` to `.env`

[.env.example](./.env.example) is a template for the environment variables.

| KEY | VALUE                                           |
| -------- |-------------------------------------------------|
| POCKET_CONSUMER_KEY | get at https://getpocket.com/developer/apps/new |
| RESOLVED_ITEM_JSON_PATH | path for `resolved.json` (see above)            |
| OUTPUT_FAVORITE_ITEM_LIST_FILE_PATH | output path for summary.                        |
| OUTPUT_FAVORITE_ITEM_ARCHIVE_DIR | output directory for archive.                   |

## Getting started

```shell
cd scripts
sh run.sh
```

## Notes

Below are some notes for how generate the markdown files.

* title with `/` will be converted to `-` in the filename
* title with url will be "title-unresolved" into the filename
