#!/bin/bash

# Comentário básico
echo "Hello, World!"

# Variáveis
var="Valor"
echo $var   # Acessar variável

# Entrada e Saída
read var    # Lê entrada do usuário
echo "Você digitou: $var"

# Condicional if
if [ $var -eq 10 ]; then
  echo "Igual a 10"
elif [ $var -gt 10 ]; then
  echo "Maior que 10"
else
  echo "Menor que 10"
fi

# Loops
for i in {1..5}; do
  echo "Iteração $i"
done

count=0
while [ $count -lt 5 ]; do
  echo "Contagem: $count"
  ((count++))
done

count=0
until [ $count -ge 5 ]; do
  echo "Contagem: $count"
  ((count++))
done

# Operadores Aritméticos
a=$((5 + 3))    # Soma
b=$((a - 2))    # Subtração
c=$((b * 2))    # Multiplicação
d=$((c / 2))    # Divisão
e=$((c % 3))    # Módulo (resto da divisão)
f=$((c ** 2))   # Exponenciação
echo "Operações aritméticas: Soma=$a Subtração=$b Multiplicação=$c Divisão=$d Módulo=$e Potência=$f"

# Operadores Lógicos
# &&: E lógico (ambas condições devem ser verdadeiras)
# ||: OU lógico (uma ou ambas condições devem ser verdadeiras)
# !: NÃO lógico (inverte a condição)
if [ $a -gt 5 ] && [ $b -lt 10 ]; then
  echo "Condições atendidas: a > 5 E b < 10"
fi

if [ $a -lt 5 ] || [ $b -lt 10 ]; then
  echo "Pelo menos uma condição é verdadeira: a < 5 OU b < 10"
fi

if ! [ $a -eq 5 ]; then
  echo "a não é igual a 5"
fi

# Funções
minha_funcao() {
  echo "Executando a função"
  return 0
}
minha_funcao

# Manipulação de Sinais
trap "echo Capturado CTRL+C; exit" SIGINT  # Captura CTRL+C

# Case
case $var in
  1) echo "Opção 1";;
  2) echo "Opção 2";;
  *) echo "Outro";;
esac

# Operadores de Comparação Numéricos
# -eq: igual a
# -ne: diferente de
# -gt: maior que
# -ge: maior ou igual a
# -lt: menor que
# -le: menor ou igual a
if [ $a -eq $b ]; then
  echo "a é igual a b"
fi

# Operadores de Comparação de Strings
# =: igual
# !=: diferente
# -z: string vazia
# -n: string não vazia
str1="Hello"
str2="World"
if [ "$str1" = "$str2" ]; then
  echo "Strings iguais"
fi

if [ -z "$str1" ]; then
  echo "String vazia"
fi

# Operadores de Comparação de Arquivos
# -e: arquivo existe
# -f: é um arquivo regular
# -d: é um diretório
# -r: tem permissão de leitura
# -w: tem permissão de escrita
# -x: é executável
# -s: arquivo não está vazio
if [ -e "meuarquivo.txt" ]; then
  echo "Arquivo existe"
fi

if [ -d "/meu/diretorio" ]; then
  echo "É um diretório"
fi

# Aritmética avançada
result=$((5 + 3))
echo "Resultado: $result"

# Arrays
array=("valor1" "valor2" "valor3")
echo "Primeiro elemento: ${array[0]}"
echo "Todos os elementos: ${array[@]}"
for item in "${array[@]}"; do
  echo "Item: $item"
done

# Substituição de Comandos
data=$(date)
echo "Data atual: $data"

# Redirecionamentos de Entrada/Saída
echo "Texto" > arquivo.txt   # Redireciona saída para arquivo
cat < arquivo.txt            # Redireciona entrada do arquivo
echo "Texto adicional" >> arquivo.txt  # Adiciona ao arquivo
cat arquivo.txt

# Herança de Variáveis
export minha_var="valor"
bash -c 'echo "Variável herdada: $minha_var"'

# Processamento de Argumentos
echo "Número de argumentos: $#"
echo "Todos os argumentos: $@"
if [ $# -gt 0 ]; then
  echo "Primeiro argumento: $1"
fi
