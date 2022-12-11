#!/bin/sh
# VARS
MAINDIR="LEGOs"
FILEZIP="./enunciado/lego.zip"
FILESETS="./temp/sets.tsv"
FILEPARTSETS="./temp/parts_sets.tsv"
FILEPARTS="./temp/parts.tsv"
TEMPDIR="./temp"

# Functions
checkFile() {
  file=$1
  if [ ! -f "$file" ]; then
    echo "O ficheiro $file não existe!"
    exit
  fi
}

printInfo() {
  theme=$1
  year=$2
  name=$3
  setnum=$4

  sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$theme_set.*\|$theme_year\|$theme_name")
  echo "$sets" | while IFS="|" read setnum name year theme; do
    if [ $theme != $theme_name ]; then
      continue
    fi

    theme=$(echo "$theme" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
    name=$(echo "$name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')

    parts_sets=$(cat "$FILEPARTSETS" | grep -w "$setnum" | sed -e 's/\t/|/g')
    [ ! -n "$parts_sets" ] && return
    printf "Class\t\tPart_Num\t\tPart_Name\t\t\t\t\t\tQty\n"
    echo "$parts_sets" | while IFS="|" read setn qty part_num; do

      parts=$(cat "$FILEPARTS" | grep -w "$part_num" | sed -e 's/\t/|/g')
      [ ! -n "$parts" ] && break

      echo "$parts" | while IFS="|" read pnum part_name class stock; do
        printf '%s\t%s\t%s\t\t\t\t%d\n' "$class" "$part_num" "$part_name" "$qty"
      done

    done

  done
  echo "\n"
}

checkDir() {
  path=$1
  if [ ! -d "$path" ]; then
    echo "O diretorio $path não existe!"
    exit
  fi
}

deleteSET() {
  theme=$1
  year=$2
  name=$3
  setnum=$4

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

createSET() {
  theme_name=$1
  theme_year=$2
  theme_set=$3

  sets=$(cat "$FILESETS" | tail -n +2 | sed -e 's/\t/|/g' | grep -iE "$theme_set.*\|$theme_year\|$theme_name")
  echo "$sets" | while IFS="|" read setnum name year theme; do
    if [ $theme != $theme_name ]; then
      continue
    fi

    theme=$(echo "$theme" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
    name=$(echo "$name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')

    parts_sets=$(cat "$FILEPARTSETS" | grep -w "$setnum" | sed -e 's/\t/|/g')
    [ ! -n "$parts_sets" ] && return

    mkdir -p "$MAINDIR/$theme/$year/$name-$setnum"

    echo "$parts_sets" | while IFS="|" read setn qty part_num; do

      parts=$(cat "$FILEPARTS" | grep -w "$part_num" | sed -e 's/\t/|/g')
      [ ! -n "$parts" ] && break

      echo "$parts" | while IFS="|" read pnum part_name class stock; do
        part_name=$(echo "$part_name" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
        class=$(echo "$class" | sed -e 's/^[[:space:]]*//' | sed -e 's/[^A-Za-z0-9_-]/_/g' | sed 's/\_$//')
        echo "$part_num|$part_name|$qty" >> "$MAINDIR/$theme/$year/$name-$setnum/$class.txt"
        echo "Ficheiro criado com sucesso -> $MAINDIR/$theme/$year/$name-$setnum/$class.txt"
      done

    done

  done
}

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
    read option

    if [ $option != "exit" ]; then
      option=$(cat "$TEMPDIR/option.txt" | grep -w "$option" | sed -e "s/^$option- *//")
      listYears $option
    else
      break
    fi

  done
}

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
    num_lines=$(wc --lines < "$TEMPDIR/option.txt")
    num_lines=$((num_lines - 1))
    printf 'Total de temas encontrados: %d\n' "$num_lines"

    echo "Indique o ID do tema"
    read option

    [ ! -n "$option" ] && continue

    if [ $option != "exit" ]; then
      option=$(cat "$TEMPDIR/option.txt" | grep -w "$option" | sed -e "s/^$option- *//")
      listYears $option
    fi

  done
}

# Introdução
echo "Bem vindo ao Trabalho Prático 02\r
de Laboratórios de Informática\r
do aluno 17694\r
do curso LESI-PL"

if [ ! -f "$FILEZIP" ]; then
  echo 'O ficheiro lego.zip não existe por favor coloque o mesmo dentro da pasta enunciado!'
  exit
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

  #  listThemes
  searchThemes
else
  echo "Não foi executado qualquer comando!"
fi

echo "Bye!!!!"
IFS=$OLDIFS