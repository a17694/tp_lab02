#!/bin/sh
# VARS
MAINDIR="LEGOs"
FILEZIP="./enunciado/lego.zip"
FILESETS="./temp/sets.tsv"
FILEPARTSETS="./temp/parts_sets.tsv"
FILEPARTS="./temp/parts.tsv"
TEMPDIR="./temp"

# Functions

# Verifica se file existe
# file - caminho do ficheiro a verificar
checkFile() {
  file=$1
  if [ ! -f "$file" ]; then
    echo "O ficheiro $file não existe!"
    exit
  fi
}

# Verifica se a pasta existe
# path - caminho da pasta a verificar
checkDir() {
  path=$1
  if [ ! -d "$path" ]; then
    echo "O diretorio $path não existe!"
    exit
  fi
}

# Cria ficheiro zip
# path - caminho da pasta
# name - nome para o ficheiro .zip
zipPath() {
  path=$1
  name=$2

  checkDir $path

  zip -r "$name.zip" $path
  printf "O ficheiro %s.zip foi criado com sucesso!\n" "$name"
}

# Apresenta o conjunto pretendido
# theme_name - nome do tema
# theme_year - ano pretendido
# theme_set - numero do set
printInfo() {
  theme_name=$1
  theme_year=$2
  theme_set=$3

  checkFile $FILESETS
  sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$theme_set.*\|$theme_year\|$theme_name")
  echo "$sets" | while IFS="|" read setnum name year theme; do
    if [ $theme != $theme_name ]; then
      continue
    fi

    theme=$(echo "$theme" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
    name=$(echo "$name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')

    checkFile $FILEPARTSETS
    parts_sets=$(cat "$FILEPARTSETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$setnum\|.*\|.*")
    [ ! -n "$parts_sets" ] && return
    printf "Class\t\tPart_Num\t\tPart_Name\t\t\t\t\t\tQty\n"
    echo "$parts_sets" | while IFS="|" read setn qty part_num; do

      checkFile $FILEPARTS
      parts=$(cat "$FILEPARTS" | sed -e 's/\t/|/g' | grep -iE "$part_num\|.*\|.*\|.*")
      [ ! -n "$parts" ] && break

      echo "$parts" | while IFS="|" read pnum part_name class stock; do
        printf '%s\t%s\t%s\t\t\t\t%d\n' "$class" "$part_num" "$part_name" "$qty"
      done

    done

  done
  echo "\n"
}

# Apaga o conjunto pretendido
# theme_name - nome do tema
# theme_year - ano pretendido
# theme_set - numero do set
deleteSET() {
  theme_name=$1
  theme_year=$2
  theme_set=$3

  checkFile $FILESETS
  sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$theme_set.*?\|$theme_year\|$theme_name")
  echo "$sets" | while IFS="|" read setnum name year theme; do
    if [ $theme != $theme_name ]; then
      continue
    fi
    theme=$(echo "$theme" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
    name=$(echo "$name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
    path="$MAINDIR/$theme/$year/$name-$setnum"
    if [ -d "$path" ]; then
      rm -rf "$path"
    else
      echo "O diretorio $path não existe!"
    fi
  done
}

# Cria o conjunto pretendido
# theme_name - nome do tema
# theme_year - ano pretendido
# theme_set - numero do set
createSET() {
  theme_name=$1
  theme_year=$2
  theme_set=$3

  checkFile $FILESETS
  sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$theme_set.*\|$theme_year\|$theme_name")
  echo "$sets" | while IFS="|" read setnum name year theme; do
    if [ "$theme" != "$theme_name" ]; then
      continue
    fi

    theme=$(echo "$theme" | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
    name=$(echo "$name" | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')

    checkFile $FILEPARTSETS
    parts_sets=$(cat "$FILEPARTSETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$setnum\|.*\|.*")
    [ ! -n "$parts_sets" ] && continue

    path="$MAINDIR/$theme/$year/$name-$setnum"
    if [ ! -d "$path" ]; then
      mkdir -p "$path"
    fi
    echo "$parts_sets" | while IFS="|" read setn qty part_num; do

      checkFile $FILEPARTS
      parts=$(cat "$FILEPARTS" | sed -e 's/\t/|/g' | grep -iE "$part_num\|.*\|.*\|.*")
      [ ! -n "$parts" ] && continue
      echo "$parts" | while IFS="|" read pnum part_name class stock; do
        part_name=$(echo "$part_name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
        class=$(echo "$class" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
        echo "$pnum\t$part_name\t$qty" >>"$path/$class.txt"
        echo "Ficheiro criado com sucesso -> $path/$class.txt"
      done
    done
  done
}

# Cria todos ou apenas um conjunto
# theme_name - nome do tema ou null
createAllSETS() {
  theme_name=$1

  checkFile $FILESETS
  if [ -z $theme_name ]; then
    themes=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | sort -t'|' -u -k4)
  else
    themes=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE ".*\|.*\|.*\|$theme_name" | sort -t'|' -u -k4)
  fi
  echo "$themes"
  echo "$themes" | while IFS="|" read setnum name year theme_name; do
    sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE ".*\|.*\|.*\|$theme_name" | sort -t'|' -k3)
    echo "$sets" | while IFS="|" read setnum name year theme; do

      createSET $theme $year $setnum

    done

  done
  return
}

# Lista opções para o conjunto pretendido
# theme_name - nome do tema
# theme_year - ano pretendido
# theme_set - numero do set
listOptions() {
  theme_name=$1
  theme_year=$2
  theme_set=$3

  checkFile $FILESETS
  option=0
  while [ "$option" != "exit" ]; do
    sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$theme_set.*\|$theme_year\|$theme_name")
    [ ! -n "$sets" ] && return

    echo "1- Criar Diretorio do conjunto\n2- Ver Conjunto\n3- Eliminar Conjunto"
    read option

    [ ! -n "$option" ] && continue

    if [ $option = "back" ]; then
      return
    fi

    if [ $option = "1" ]; then
      createSET $theme_name $theme_year $theme_set
    fi

    if [ $option = "2" ]; then
      printInfo $theme_name $theme_year $theme_set
    fi

    if [ $option = "3" ]; then
      deleteSET $theme_name $theme_year $theme_set
    fi

  done
}

# Lista todos os conjuntos de um tema e ano selecionado
# theme_name - nome do tema
# theme_year - ano pretendido
listName() {
  theme_name=$1
  theme_year=$2

  checkFile $FILESETS
  i=1
  option=0
  while [ "$option" != "exit" ]; do
    echo "" >"$TEMPDIR/option.txt"
    echo "ID\tNome"
    sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "\|$theme_year\|$theme_name" | sort -t'|' -k2)
    echo "$sets" | while IFS="|" read setnum name year theme; do

      echo "$i- $setnum" >>"$TEMPDIR/option.txt"

      theme=$(echo "$theme" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
      name=$(echo "$name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
      echo "$i- $name-$setnum"
      i=$((i + 1))
    done
    read option

    [ ! -n "$option" ] && continue

    if [ $option = "back" ]; then
      return
    fi

    if [ $option != "exit" ]; then
      option=$(cat "$TEMPDIR/option.txt" | grep -w "$option" | sed -e "s/^$option- *//")
      listOptions $theme_name $theme_year $option
    fi
  done
}

# Lista todos os anos de um tema selecionado
# theme_name - nome do tema
listYears() {
  theme_name=$1

  [ ! -n "$theme_name" ] && return

  checkFile $FILESETS
  i=1
  option=0
  while [ "$option" != "exit" ]; do
    echo "" >"$TEMPDIR/option.txt"
    echo "ID\tAno"
    sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE ".*\|.*\|.*\|$theme_name" | sort -t'|' -u -k3)
    [ ! -n "$sets" ] && return

    echo "$sets" | while IFS="|" read setnum name year theme; do
      #Tema / Ano / Conjunto
      [ ! -n "$setnum" ] && return
      if [ $theme != $theme_name ]; then
        continue
      fi
      echo "$i- $year" >>"$TEMPDIR/option.txt"
      echo "$i- $year"
      i=$((i + 1))
    done
    read option

    [ ! -n "$option" ] && continue

    if [ $option = "back" ]; then
      return
    fi

    if [ $option != "exit" ]; then
      option=$(cat "$TEMPDIR/option.txt" | grep -w "$option" | sed -e "s/^$option- *//")
      listName $theme_name $option
    fi
  done
}

# Lista todos os temas contidos no file tsv
listThemes() {
  checkFile $FILESETS
  i=1
  while [ "$option" != "exit" ]; do
    echo "" >"$TEMPDIR/option.txt"
    echo "ID\tTema"
    sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | sort -t'|' -u -k4)
    echo "$sets" | while IFS="|" read setnum name year theme; do
      #Tema / Ano / Conjunto
      echo "$i- $theme" >>"$TEMPDIR/option.txt"
      theme=$(echo "$theme" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
      #name=$(echo "$name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
      echo "$i- $theme"
      i=$((i + 1))
    done
    read -r option

    [ -z "$option" ] && continue

    if [ "$option" = "back" ]; then
      return
    fi

    if [ "$option" != "exit" ]; then
      option=$(cat "$TEMPDIR/option.txt" | grep -w "$option" | sed -e "s/^$option- *//")
      listYears $option
    fi

  done
}

# Pesquisa por temas contidos no file tsv
searchThemes() {
  checkFile $FILESETS
  i=1
  while [ "$option" != "exit" ]; do
    echo "Qual é o tema que deseja procurar?"
    read search

    [ ! -n "$search" ] && continue

    echo "" >"$TEMPDIR/option.txt"
    echo "ID\tTema"
    sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE ".*\|.*\|.*\|$search" | sort -t'|' -u -k4)
    [ ! -n "$sets" ] && continue
    echo "$sets" | while IFS="|" read setnum name year theme; do

      echo "$i- $theme" >>"$TEMPDIR/option.txt"
      #theme=$(echo "$theme" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
      #name=$(echo "$name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
      echo "$i- $theme"
      i=$((i + 1))
    done
    num_lines=$(wc --lines <"$TEMPDIR/option.txt")
    num_lines=$((num_lines - 1))
    printf 'Total de temas encontrados: %d\n' "$num_lines"

    echo "Indique o ID do tema:"
    read option

    [ ! -n "$option" ] && continue

    if [ $option != "exit" ]; then
      option=$(cat "$TEMPDIR/option.txt" | grep -w "$option" | sed -e "s/^$option- *//")
      listYears $option
    fi

  done
}

# Criar o tema completo selecionado
createFullTheme() {
  checkFile $FILESETS
  i=1
  while [ "$option" != "exit" ]; do
    echo "Qual é o tema que deseja criar?"
    read search

    [ ! -n "$search" ] && continue

    echo "" >"$TEMPDIR/option.txt"
    echo "ID\tTema"
    sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE ".*\|.*\|.*\|$search" | sort -t'|' -u -k4)
    [ ! -n "$sets" ] && continue
    echo "$sets" | while IFS="|" read setnum name year theme; do

      echo "$i- $theme" >>"$TEMPDIR/option.txt"
      echo "$i- $theme"
      i=$((i + 1))
    done
    num_lines=$(wc --lines <"$TEMPDIR/option.txt")
    num_lines=$((num_lines - 1))
    printf 'Total de temas encontrados: %d\n' "$num_lines"

    echo "Indique o ID do tema:"
    read option

    [ ! -n "$option" ] && continue

    if [ $option != "exit" ]; then
      option=$(cat "$TEMPDIR/option.txt" | grep -w "$option" | sed -e "s/^$option- *//")
      createAllSETS $option
    fi

  done
}

# Menu
menu() {
  option=0
  while [ "$option" != "exit" ]; do
    echo "MENU"
    echo "1- Listar Todos os temas"
    echo "2- Procurar Temas"
    echo "3- Criar Tema completo"
    echo "4- Criar todos os temas"
    echo "5- Comprimir pasta LEGOs"
    echo "back- Voltar"
    echo "exit- Sair"
    echo "Digite a opção pretendida:"
    read -r option

    [ "$option" = "exit" ] && continue

    if [ -z "$option" ] || [ $option -le 0 ]; then
      continue
    fi

    case $option in
    1)
      listThemes
      continue
      ;;
    2)
      searchThemes
      continue
      ;;
    3)
      createFullTheme
      continue
      ;;
    4)
      createAllSETS
      continue
      ;;
    5)
      zipPath LEGOs LEGOs
      continue
      ;;
    6) ;;

    esac
  done
}

# APP

# Introdução
echo "Bem vindo ao Trabalho Prático 02\r
de Laboratórios de Informática\r
do aluno 17694\r
do curso LESI-PL"

if [ ! -f "$FILEZIP" ]; then
  echo 'O ficheiro lego.zip não existe por favor coloque o mesmo dentro da pasta enunciado!'
  exit
fi

if [ -d "./LEGOs" ]; then
  rm -rf LEGOs
fi

OLDIFS=$IFS

echo "Deseja realmente prosseguir?[n/S]"
read -r text

if [ -n "$text" ] && [ "$text" = s ] || [ "$text" = S ]; then
  echo "------Iniciado------"

  # Descompactar os ficheiros zip do enunciado
  if [ ! -d "./temp" ]; then
    echo 'A desconpactar o ficheiro lego.zip'
    unzip "$FILEZIP" -d ./temp
  fi

  # Apresenta o menu
  menu

else
  echo "Não foi executado qualquer comando!"
fi

echo "Bye!!!!"
IFS=$OLDIFS
