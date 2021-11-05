#!/bin/bash
logado=0 #Checa se o usuário está logado
sair=0 #Torna 1 quando o usuário deseja fechar o programa


function createuser {
  
  if ! [[ -e usuarios.txt ]]; then  #Checa se já existe algum usuário
    #Cria um diretório para guardar os usuários e suas senhas:
    echo "user: $args0 password: $args1" | cat > usuarios.txt
    mkdir -p $args0 #Cria diretório do usuário criado para futuramente guardar suas mensagens
  else
    if [[ $( grep -w "user: $args0" usuarios.txt ) == "" ]]; then #Checa se o nome de usuário ja existe
      echo "user: $args0 password: $args1" | cat >> usuarios.txt #Adiciona o novo usuário e senha ao diretório usuários.txt
      mkdir -p $args0
    else 
      echo "Esse username já existe"
    fi
  fi

}

function passwd {

  if [[ $( grep -w "user: $args0" usuarios.txt ) != "user: $args0 password: $args1" ]]; then #Checa se usuário e senha estão corretas
    echo "usuario ou senha incorreta"
  else
    original="user: $args0 password: $args1"
    novaSenha="user: $args0 password: $args2"
    sed -i "s/$original/$novaSenha/g" usuarios.txt #Muda a senha do usuário
  fi

}

function login {

  if [[ $( grep -w "user: $args0" usuarios.txt ) != "user: $args0 password: $args1" ]]; then #Checa se usuário e senha estão corretas
    echo "usuario ou senha incorreta"
  else
    logado=1 #Muda estado para logado
    usuario=$args0 #Guarda o nome do usuário logado no momento
    echo "Login efetuado com sucesso"
  fi

}

function listusers {
  if [ $logado -eq 0 ]; then #Checa se está logado
    echo "Você precisa estar logado para executar esse comando"
  else
IFS='
'
    for linha in $( cat usuarios.txt ); do #Percorre cada linha do arquivo usuarios.txt
      IFS=' ' #Permite percorrer cada palavra na linha
      local x=0
      for palavra in $linha; do  #Percorre a linha atual
        let x=x+1
        if [[ $x == 2 ]]; then  #Por padrão do programa, o username é a segunda palavra da linha 
          echo $palavra  #Imprime o nome de um usuário existente
        fi
      done
IFS='
'  #Retorna a percorrer linha por linha
    done
  fi
}

function msg {

  if [ $logado -eq 0 ]; then #Checa se está logado
    echo "Você precisa estar logado para executar esse comando"
  else
    if [[ $( grep -w "user: $args0" usuarios.txt ) == "" ]]; then #Checa se o username fornecido existe
      echo "Esse usuário não existe"
    else
      echo "Qual a mensagem? Termine com 'CTRL-D'"
IFS='
'
      maior=0
      for ARQ in $( ls ./$args0 ); do  #Percorre os nomes dos arquivos (mensagens) que o destinatário possui para checar qual o número da próxima msg
        local numAtual=${ARQ:0:1}  #Número da mensagem atual
        if [ $numAtual -gt $maior ]; then
          maior=$numAtual  #Guarda o número da maior mensagem
        fi
      done
      local numMsg=$[$maior + 1] #Número da próxima msg a ser enviada
      echo -e "De: $usuario" | cat > ./$args0/"$numMsg | N | $( date ) | $usuario" #Cria arquivo para mensagem que será enviada no diretório do destinatário
      cat >> ./$args0/"$numMsg | N | $( date ) | $usuario" #Lê a mensagem a ser enviada

    fi
  fi

}


function list {
  if [ $logado -eq 0 ]; then  #Checa se está logado
    echo "Você precisa estar logado para executar esse comando"
  else
IFS='
'
      for ARQ in $( ls ./$usuario ); do  #Percorre os nomes dos arquivos (mensagens) que o usuário possui
        echo $ARQ #Imprime o nome da mensagem
      done
    
  fi
}

function readmsg {
  if [ $logado -eq 0 ]; then  #Checa se está logado
    echo "Você precisa estar logado para executar esse comando"
  else
IFS='
'
    for ARQ in $( ls ./$usuario ); do #Percorre os nomes dos arquivos (mensagens) que o usuário possui
      if [[ ${ARQ:0:1} == $args0 ]]; then #Checa se é a mensagem que do número desejado
        msgName=$ARQ
      fi
    done
    cat "./$usuario/$msgName" #Mostra a mensagem 
    cd ./$usuario
    local espaco=" "
    local DESTINO=$( echo $( ls $msgName )  |  sed -e "s/N/$espaco/" ) 
    mv "$msgName" "$DESTINO" #Troca o status da mensagem (tira o N se tiver)
    cd ..
  fi
}

function unread {  
  if [ $logado -eq 0 ]; then  #Checa se está logado
    echo "Você precisa estar logado para executar esse comando"
  else
IFS='
'
    for ARQ in $( ls ./$usuario ); do #Percorre os nomes dos arquivos (mensagens) que o usuário possui
      if [[ ${ARQ:0:1} == $args0 ]]; then #Checa se é a mensagem que do número desejado
        msgName=$ARQ
      fi
    done

    cd ./$usuario
    local N="$args0 | N"
    local espaco="$args0 |  "
    local DESTINO=$( echo $( ls $msgName ) | sed -e "s/$espaco/$N/" )
    mv "$msgName" "$DESTINO" #Troca o status da mensagem para N
    cd ..
  fi
}

function delete {
  if [ $logado -eq 0 ]; then  #Checa se está logado
    echo "Você precisa estar logado para executar esse comando"
  else
IFS='
'
    for ARQ in $( ls ./$usuario ); do #Percorre os nomes dos arquivos (mensagens) que o usuário possui
      if [[ ${ARQ:0:1} == $args0 ]]; then #Checa se é a mensagem que do número desejado
        msgName=$ARQ
      fi
    done
    rm "./$usuario/$msgName" #Remove a mensagem
  fi
}

function quit {
  echo "Bye bye"
  sair=1
}


while [ $sair -ne 1 ]; do #Ler a entrada do usuário enquanto ele não digita quit
  echo -n "simplemail> "
  IFS=' '
  read COMANDO args0 args1 args2 #Lê comando e argumentos

  $COMANDO #Executa comando
done
