i = 0
for file in *.jpg
do
  mv $file img$i.png
((i++))
done