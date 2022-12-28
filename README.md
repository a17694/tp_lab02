# Laboratórios de Informática
### Licenciatura em Engenharia de Sistemas Informáticos
#### 2022/2023

## Trabalho Prático 02 (T2)
#### Linux -shell bash 
#### Aluno 17694 - João Ponte

***
* para descompactar o ficheiro legos.zip foi usado o comando ``unzip legos.zip -d ./temp`` e assim os ficheiros nele contidos foram colocados dentro da pasta criada **temp**
* comando ``cat file`` para ver a informação contida nos ficheiros .tsv ex.(``cat ./temp/sets.tsv``)
* o comando ``grep options`` foi usado para auxiliar na pesquisa e filtragem dos dados pretendidos.
* foi tambem utilizado o comando ``sed -e 's/	/|/g'`` para converter todos os delimitadores [TAB] em pipes(|) para facilitar a visualização da informação
* para criar a estrutura de pastas foi utilizado
    o comando ``mkdir -p caminho`` ex.(``mkdir -p LEGOs/Avatar/2006/Fire_Nation_Ship-3829-1``)
* para criação dos ficheiros relativos às classes de cada conjunto foi utilizado o comando ``echo`` ex.(``echo '3857	Baseplate_16_x_32	1' >> ./LEGOs/Avatar/2006/Air_Temple-3828-1/Bars__Ladders_and_Fences.txt``)
* para comprimir a pasta legos no ficheiro **primeira.zip** foi usado o comando ``zip -r primeira.zip ./LEGOS``
***
