#!/bin/sh
if [ ! -f "./primeira.zip" ]; then
  echo 'O ficheiro primeira.zip não existe por favor coloque o mesmo aqui na raiz do projecto!'
  exit
fi

echo "Apaga pasta LEGOs"
rm -rf LEGOs

echo "Descompacta o ficheiro primeira.zip"
unzip ./primeira.zip

if [ ! -d "./LEGOs" ]; then
  echo "Nao existe a pasta LEGOs"
  exit
fi

echo "Lista temas contidos na pasta LEGOs:"
ls LEGOs | sort

printf "\nDigite o tema a consultar:"
read theme
echo "Lista de anos contidos no tema $theme:"
ls "LEGOs/$theme" | sort

printf "\nDigite o ano a consultar:"
read year
echo "Lista de conjuntos contidos no tema $theme e ano $year:"
ls "LEGOs/$theme/$year" | sort

printf "\nDigite o conjunto a consultar:"
read name
ls "LEGOs/$theme/$year/$name" | sort | while IFS= read -r string; do echo "$string" | sed -e 's/.txt//g' && (cat "LEGOs/$theme/$year/$name/$string" | tr a-z A-Z | sed -e 's/\t/|/g' | sort -t'|' -rnk3 | sed -e 's/|/\t/g') && printf "\nTotal parts %d\n" $(cat "LEGOs/$theme/$year/$name/$string" | wc -l) && echo ""; done
echo "Digite [ENTER] para continuar"
read s

printf "\nAs 5 peças com mais quantidade do conjunto:\n"
ls "LEGOs/$theme/$year/$name" | sort | while IFS= read -r string; do (cat "LEGOs/$theme/$year/$name/$string" | tr a-z A-Z | sed -e 's/\t/|/g' | sort -t'|' -rnk3 ); done | sort -t'|' -rnk3 | head -n 5 | sed -e 's/|/\t/g'
echo "Digite [ENTER] para continuar"
read s

printf "\nAs 3 classes com mais peças:\n"
ls "LEGOs/$theme/$year/$name" | sort | while IFS= read -r string; do echo $(printf "%s|%d" "$(echo "$string" |  sed -e 's/.txt//g')" "$(cat "LEGOs/$theme/$year/$name/$string" | wc -l)"); done | sort -t'|' -rnk2 | head -n 3 | sed -e 's/|/\t/g'
echo "Digite [ENTER] para continuar"
read s

printf "\nDigite a class a eliminar:"
read nameclass
mkdir -p "Reciclagem/$theme/$year/$name" && cat "LEGOs/$theme/$year/$name/$nameclass.txt" > "Reciclagem/$theme/$year/$name/$nameclass.txt" && rm -i "LEGOs/$theme/$year/$name/$nameclass.txt" && ls "LEGOs/$theme/$year/$name" | sort
echo "Digite [ENTER] para continuar"
read s

printf "\nMostra os 10 maiores ficheiros relativos aos ficheiros de class do conjunto:\n"
ls -lh "LEGOs/$theme/$year/$name" | sort -rk5 | head -n 10 | while IFS= read -r string; do echo "$string" | awk -F':[0-9]* ' '/:/{print $2}'; done
echo "Digite [ENTER] para continuar"
read s

