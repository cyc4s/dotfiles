#!/bin/bash
# すべてコメントアウト済み。必要なものを有効化してください。
# Preview script for nb notes in fzf (zeno 補完用)
# 画像、フォルダ、TODO、ブックマーク等のファイルタイプに応じたプレビューを表示

# # Extract ID from fzf input
# id=$(echo "$1" | sed -E 's/^\[([^]]+)\].*/\1/')
#
# # Check if it's an image file
# if nb show "$id" --type image 2>/dev/null; then
#   file_path=$(nb show "$id" --path 2>/dev/null)
#
#   if [ -n "$file_path" ] && [ -f "$file_path" ]; then
#     nb show "$id" --info-line 2>/dev/null
#     echo "  Size: $(du -h "$file_path" 2>/dev/null | cut -f1)"
#     echo "  Modified: $(stat -f"%Sm" -t "%b %d %H:%M" "$file_path" 2>/dev/null)"
#     echo "─────────────────"
#
#     if [ -f "$file_path" ]; then
#       if command -v magick >/dev/null 2>&1; then
#         if magick "$file_path" -geometry 400x200 sixel:- 2>/dev/null; then
#           exit 0
#         fi
#       elif command -v convert >/dev/null 2>&1; then
#         if convert "$file_path" -geometry 400x200 sixel:- 2>/dev/null; then
#           exit 0
#         fi
#       fi
#
#       if command -v wezterm >/dev/null 2>&1; then
#         wezterm imgcat --width 40 --height 20 "$file_path" 2>/dev/null && exit 0
#       fi
#     fi
#
#     echo "Image preview not available"
#     echo "Path: $file_path"
#   fi
#   exit 0
# fi
#
# # Check if it's a folder
# if nb show "$id" --type folder 2>/dev/null; then
#   nb show "$id" --info-line 2>/dev/null
#   echo ""
#   echo "📂 Folder contents:"
#   echo "─────────────────"
#   nb ls "$id" --limit 10 --no-color 2>/dev/null | head -20
#   exit 0
# fi
#
# # Check if it's a TODO item
# if echo "$1" | grep -q "✔️\|✅"; then
#   nb show "$id" --info-line 2>/dev/null
#   echo ""
#   output=$(nb show "$id" --print 2>/dev/null)
#   if [ -n "$output" ]; then
#     if echo "$1" | grep -q "✅"; then
#       echo "✅ Status: COMPLETED"
#     else
#       echo "✔️  Status: TODO"
#     fi
#     echo "─────────────────"
#     echo "$output"
#   fi
#   exit 0
# fi
#
# # Check if it's a bookmark
# if nb show "$id" --type bookmark 2>/dev/null; then
#   nb show "$id" --info-line 2>/dev/null
#   echo ""
#   echo "🔖 Bookmark details:"
#   echo "─────────────────"
#   nb show "$id" --print 2>/dev/null | head -50
#   exit 0
# fi
#
# # Default handling
# output=$(nb show "$id" --print 2>/dev/null)
# if [ -n "$output" ]; then
#   nb show "$id" --info-line 2>/dev/null
#   echo "─────────────────"
#   echo "$output" | head -100
# else
#   nb show "$id" --info-line 2>/dev/null
#
#   file_path=$(nb show "$id" --path 2>/dev/null)
#   if [ -n "$file_path" ] && [ -f "$file_path" ]; then
#     echo ""
#     echo "📋 File info:"
#     echo "  Size: $(du -h "$file_path" 2>/dev/null | cut -f1)"
#     echo "  Modified: $(stat -f"%Sm" -t "%b %d %H:%M" "$file_path" 2>/dev/null)"
#   fi
#
#   if nb show "$id" --type audio 2>/dev/null; then
#     echo ""
#     echo "🎵 Audio file - Use 'nb show $id' to play"
#   elif nb show "$id" --type video 2>/dev/null; then
#     echo ""
#     echo "🎬 Video file - Use 'nb show $id' to play"
#   elif nb show "$id" --type archive 2>/dev/null; then
#     echo ""
#     echo "📦 Archive file - Use 'nb show $id' to extract"
#   elif nb show "$id" --type ebook 2>/dev/null; then
#     echo ""
#     echo "📖 E-book file - Use 'nb show $id' to read"
#   elif nb show "$id" --type document 2>/dev/null; then
#     echo ""
#     echo "📄 Document file - Use 'nb show $id' to open"
#   fi
# fi
