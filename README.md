<h1 align="center"> 2_Atividade_PB_Compass </h1>
<h3 align="center"> Prática Docker/AWS utilizando RDS, EFS, AutoScaling e LoadBalancer</h3>
<h6 align="center">Este repositório contém a segunda atividade avaliativa do programa de estágio da Compass.UOL. A execução da atividade proposta é descrita na documentação abaixo e envolveu conhecimentos de Amazon Web Services (AWS), Linux e Docker.</h6>


<p align="center">
  <a href="#-Objetivo">Objetivo</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Descrição-dos-requisitos">Descrição dos requisitos</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Pontos-de-atenção">Pontos de atenção</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Instruções-de-Execução">Instruções de Execução</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Referências">Referências</a>
</p>


## 🚀 Objetivo

Contruir e documentar o processo de criação e configuração da seguinte arquitetura:
<p align="center">
  <img src="https://i.ibb.co/8PRmxdW/arquitetura.png"/>
</p>


<br>

## 💻 Descrição dos requisitos

<li> Instalar e configurar o DOCKER ou CONTAINERD no host EC2;
<li> Utilizar a instalação via script de Start Instance (user_data.sh);
<li> Efetuar Deploy de uma aplicação Wordpress com container de aplicação e RDS database Mysql;
<li> Configurar a utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress;
<li> Configurar do serviço de Load Balancer AWS para a aplicação Wordpress

<br>

## ⚠ Pontos de atenção

<li> Não utilizar ip público para saída do serviços WP (Evitar publicar o serviço WP via IP Público);
<li> É sugerido que o tráfego de internet saia pelo LB (Load Balancer);
<li> Pastas públicas e estáticos do Wordpress sugere-se utilizar o EFS (Elastic File System);
<li> Fica a critério de cada integrante (ou dupla) usar Dockerfile ou Dockercompose;
<li> Necessário demonstrar a aplicação wordpress funcionando(tela de login);
<li> A aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
<li> Utilizar repositório git para versionamento;
<li> Criar documentação
<br>

## 📝 Instruções de Execução
### >> AWS

## Criando Grupo de Segurança para as Instancias
- Na pagina do serviço EC2, no menu lateral esquerdo ir em "Rede e Segurança" e clicar em "Security groups".
- Depois em "criar grupo de segurança" no botão superior direito.
- Insira nome e descrição para o mesmo.
<p align="center">
  <img src="https://i.ibb.co/SxKT2T6/criando-grupo-seguran-a-ec2-modelo.png"/>
</p>

- Em seguida clique em adicionar regras de entrada e libere as seguintes portas.
<p align="center">
  <img src="https://i.ibb.co/whVdjt7/regra-de-seguran-a.png"/>
</p>

- Por fim clique em "Criar grupo de segurança".

### Criando grupo de segurança para o servidor de arquivos EFS
- Navegue no serviço EC2 da AWS em Security groups.
- Clique em criar grupo de segurança, este será utilizado para segurança de rede exclusiva  do EFS.
- Depois de atribuir um nome(EFS-acesso), adicione como regra de entrada ao NFS com origem para o grupo de segurança criado e anexado anteriormente junto da instancia.
Deverá ficar assim:
    Tipo | Protocolo | Intervalo de portas | Origem | Descrição
    ---|---|---|---|---
    NFS | TCP | 2049 | sg-0e0fe595c74f876a6 | NFS

- Clique em criar grupo de segurança para finalizar.

### Criando Servidor de arquivos (Elastic File System)
- Ainda no ambiente da AWS, navegue até o serviço de EFS.
- No menu lateral esquerdo clique em Sistemas de arquivos e logo após em "Criar sistema de arquivos" a direita.
- Adicione um nome para o mesmo(EFSatividadePB) e selecione a opção "personalizar".
- Marque a opção "One Zone" e selecione a zona de disponibilidade na qual criou sua instancia.
- Mantenha o restante das opções pré-definidas, só altere o grupo de segurança para o "EFS-acesso" criado anteriormente.
- Revise e clique em criar para finalizar.
- Abra o sistema de arquivos criado e clique no botão "anexar" a esquerda para visualizar as opções de montagem(IP ou DNS).
- A AWS já te dá os comandos definidos de acordo com as opções escolhidas, nesse caso vamos utilizar a montagem via DNS usando o cliente do NFS, copie o mesmo. Como no exemplo abaixo:
```
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-07d84686cb6d691f7.efs.us-east-1.amazonaws.com:/ efs
```

## Criando RDS(MySQL)
- Acesse o serviço RDS na sua conta AWS, no canto lateral esquerdo clique em "Banco de dados".
- Clique no botão laranja no canto superior direito em "Criar banco de dados".
- Selecione o métode de "criação fácil "e "MySQL" como banco de configuração.
<p align="center">
  <img src="https://i.ibb.co/LpTs8ss/tipo-de-banco-RDS.png"/>
</p>

- Selecione também o "nível gratuito" e preencha as credenciais do banco como na imagem(não esqueça de gravá-las).
<p align="center">
  <img src="https://i.ibb.co/Zft94wt/credenciais-RDS.png"/>
</p>

- Por último clique em "criar banco de dados" no canto inferior da tela e aguarde a criação, isso pode levar alguns minutos.

### Executando instancia EC2 
- Acessar a AWS na pagina do serviço EC2, e clicar em "instancias" no menu lateral esquerdo.
- Clicar em "executar instâncias" na parte superior esquerda da tela.
- Abaixo do campo de inserir nome clicar em "adicionar mais tags".
- Crie e insira o valor para as chaves: Name, Project e CostCenter, selecionando "intancias", "volume" e "interface de rede" como tipos de recurso e adicionando os valores de sua preferencia.
<p align="center">
  <img src="https://i.ibb.co/RTtkcTf/Instancia-modelo.png"/>
</p>

- Abaixo selecione também a AMI Amazon Linux 2(HVM) SSD Volume Type.
- Selecionar como tipo de intância a família t3.small.
- Em Par de chaves login clique em "criar novo par de chaves".
- Insira o nome do par de chaves, tipo RSA, formato .ppk e clique em "criar par de chaves".
<p>
  <img src="https://i.ibb.co/qNY3SVY/criando-par-de-chaves.png"/>
</p>

- Em configurações de rede, selecione criar grupo de segurança e permitir todos tráfegos(SSH).
- Configure o armazenamento com 16GiB, volume raiz gp2.
- No final da configuração expanda o link "configurações avançadas"
<p align="center">
  <img src="https://i.ibb.co/mBQtgkx/detalhes-avan-ados-criando-instaqncia.png"/>
</p>

- Em dados do usuário cole o script abaixo(lembre-se de substituir o valor das variáveis de ambiente pelo valor das váriáveis que você criou no RDS e o ID do seu EFS):
```
#!/bin/bash
yum update -y
yum install -y docker
service docker start
chkconfig docker on
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
usermod -aG docker ec2-user
yum install -y git
mkdir /mnt/efs
mkdir /mnt/efs/wordpress
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-XXXXXXXXXXXX.amazonaws.com:/ /mnt/efs

export WORDPRESS_DB_HOST="XXXXX"
export WORDPRESS_DB_USER="XXXXX"
export WORDPRESS_DB_PASSWORD="XXXXX" 
export WORDPRESS_DB_NAME="XXXXX"

cd /home/ec2-user
git clone https://github.com/KerenOlmedo/2_Atividade_PB_Compass.git
cd 2_Atividade_PB_Compass
docker-compose up -d
```
- Deverá ficar semelhante como na imagem abaixo.
<p align="center">
  <img src="https://i.ibb.co/hyZ9Gcc/script-start-instance.png"/>
</p>

- Este script atualiza o sistema, instala o Docker e o Docker Compose, configura um ambiente WordPress, clona um repositório Git e inicia os contêineres usando o Docker Compose. 

Explicação detalhada das linhas de comando:

1. Indica o interpretador a ser usado para executar o script, neste caso, o Bash.
2. Atualiza todos os pacotes do sistema operacional usando o gerenciador de pacotes yum e a opção -y responde automaticamente "sim" para todas as solicitações de confirmação.
3. Instala o Docker usando o yum e a opção -y responde automaticamente "sim" para todas as solicitações de confirmação.
4. Inicia o serviço do Docker.
5. Configura o serviço do Docker para iniciar automaticamente na inicialização do sistema.
6. Faz o download do Docker Compose da versão especificada no URL e o salva no diretório /usr/local/bin/docker-compose.
7. Concede permissão de execução ao arquivo do Docker Compose.
8. Adiciona o usuário ec2-user ao grupo docker, permitindo que o usuário execute comandos Docker sem a necessidade de privilégios de root.
9. Instala o Git usando o yum e a opção -y responde automaticamente "sim" para todas as solicitações de confirmação.
10. Cria o diretório /mnt/efs.
11. Cria o diretório /mnt/efs/wordpress.
12. Monta o sistema de arquivos NFS especificado em /mnt/efs.
13. Define a variável de ambiente WORDPRESS_DB_HOST especificando o nome do serviço do banco de dados (db) para o WordPress se conectar.
14. Define a variável de ambiente WORDPRESS_DB_USER especificando o nome de usuário do banco de dados para o WordPress.
15. Define a variável de ambiente WORDPRESS_DB_PASSWORD com a senha do usuário do banco de dados para o WordPress.
16. Define a variável de ambiente WORDPRESS_DB_NAME especificando o nome do banco de dados do WordPress.
17. Navega para o diretório /home/ec2-user.
18. Clona o repositório Git especificado no diretório atual.
19. Navega para o diretório clonado.
20. Inicia os contêineres especificados no arquivo docker-compose.yml no modo detached (em segundo plano).

- Clique em executar instância e aguarde, isso pode levar alguns minutos por conta das configurações inseridas no script de start instance.

## Testando configurações feitas via script(opcional)

Se todas configurações foram bem sucedidas o WordPress estará acessível em http://localhost:80 (ou em outra porta dependendo da configuração feita no arquivo docker-compose), substitua "localhost" pelo endereço na sua instancia EC2 e lembre-se de que é necessário que a porta 80 esteja liberada nas regras de entrada do grupo de segurança em que a mesma pertence. Deverá carregar esta pagina de instalação.
<p align="center">
  <img src="https://i.ibb.co/ygxfYc0/pagina-instala-o-wordpress.png"/>
</p>

#### Testando se o container WordPress está em execução

Caso isso não aconteça, acesse o terminal da sua instancia pela AWS ou via PUTTY.
- Para testar se o container está rodando execute o comando:
```
docker ps
```
Este comando listará os containers em execução. 
<p align="center">
  <img src="https://i.ibb.co/z23wHRZ/docker-ps.png"/>
</p>

Outra forma de verificar algum erro é acessando as logs do container. Executando o comando:
```
docker logs <ID_do_container>
```
<p align="center">
  <img src="https://i.ibb.co/4Z9M6Y4/logs-container.png"/>
</p>
Na imagem acima foram destacados apenas dois exemplos, essas mensagens de log são informações úteis para acompanhar o processo de inicialização do contêiner do Wordpress e verificar se tudo ocorreu conforme o esperado.

**"Complete! WordPress has been successfully copied to /var/www/html":** Essa mensagem indica que os arquivos do Wordpress foram copiados com sucesso para o diretório /var/www/html.

**"No 'wp-config.php' found in /var/www/html, but 'WORDPRESS_...' variables supplied; copying 'wp-config-docker.php' (WORDPRESS_DB_HOST WORDPRESS_DB_NAME WORDPRESS_DB_PASSWORD WORDPRESS_DB_USER)":** Essa mensagem indica que não foi encontrado um arquivo 'wp-config.php' no diretório /var/www/html. No entanto, o contêiner recebeu variáveis de ambiente com prefixo 'WORDPRESS_' que fornecem as informações necessárias para a configuração do banco de dados. Em vez do arquivo 'wp-config.php', o contêiner está copiando um arquivo de configuração alternativo chamado 'wp-config-docker.php', que será usado para configurar a conexão com o banco de dados com base nas variáveis de ambiente fornecidas.

#### Testando a instalação do Docker e Docker Compose

- Caso o container não esteja rodando, execute os comandos abaixo para retornar a versão do Docker e docker-compose, assim podemos nos certidicadas de que foram instalados caso retorne a versão dos mesmos.
```
docker --version
```
```
docker-compose --version
```

#### Testando a conexão com o banco MySQL (RDS)

- Acesse o container criado anteriormente através do seu ID e com o comando:
```
docker exec -it <ID_do_contêiner_wordpress> /bin/bash
```
- Depois de acessar o terminal do container tente executar o seguinte comando para testar a conexão com o RDS:
```
nc -vz <nome_do_host_do_banco_de_dados> 3306
```
 Substitua <nome_do_host_do_banco_de_dados> pelo endpoint do seu RDS lá da AWS. O comando deve retornar algo como esta mensagem de sucesso:
<p align="center">
  <img src="https://i.ibb.co/cbRGGYv/conexao-banco.png"/>
</p>

- Caso dê algum erro no comando é porque o pacote netcat não vem instalado como padrão do container. Execute os dois comandos abaixo e tente novamente.
```
apt-get update
```
```
apt-get install -y netcat
``` 
- Execute "exit" para sair do terminal do container e voltar para o da sua instancia.

Para testar se o EFS foi criado corretamente e está salvando os arquivos estáticos do WordPress acesse o diretório e montagem:
```
cd /mnt/efs/wordpress
```
- Estando dentro da pasta execute o comando "ls" para listar o contéudo da mesma. O correto é retornar os arquivos de configuração do WordPress como na imagem abaixo.
<p align="center">
  <img src="https://i.ibb.co/183nSWW/diretorio-efs-wordpress.png"/>
</p>

- Assim conseguimos testar praticamente toda aplicação mas se você ainda estiver enfrentando problemas pode executar os logs de inicialização da instancia com o comando:
```
sudo cat /var/log/cloud-init-output.log
```
Os logs de inicialização são armazenados nesses arquivos apenas se a instância tiver sido configurada para registrar logs de inicialização. Portanto, se você não encontrar informações relevantes nos logs mencionados, verifique outros arquivos de log disponíveis no diretório /var/log/ ou consulte a documentação, alguns links foram deixados como referencia neste repositório.

## Criar uma AMI a partir da minha EC2
- Acesse o serviço EC2 da AWS, em instancias selecione a que subimos o container com WordPress e as demais configurações.
- No canto superior direito clique em "Ações" > "imagem e modelos" > "criar imagem".
- Insira o nome(imagemWordpressRDS) e descrição para a mesma, observe que ela já pega as configurações pré-definidas da instancia que vamos utilizar como modelo, na qual fizemos todas configurações até agora.
- Mantenha as opções padrão e clique em "criar imagem" para concluir.

Obs: Esta AMI será utilizada como modelo para o AutoScaling criar as demais com as mesmas configurações, logo iremos aplicá-lo juntamente do LoadBalancer.

## Criar Auto Scaling Group
- Ainda no serviço de EC2 na parte inferior do menu lateral esquerdo vá em "Grupos Auto Scaling".
- Clique no botão superior direito "criar grupo de Auto Scaling".
  
### **Etapa 1** - Escolher o modelo ou a configuração de execução
- Insira um nome(autoScalingWordPress) e no canto superior da opção de modelo de execução clique em "Alterar para configuração de execução".
- Abaixo aparecerá a opção de selecionar uma configuração de execução já existente ou criar uma nova, neste caso vamos criar pois não temos nenhuma.
- Preencha o campo de nome(ModeloExecWordPress) e selecione a AMI criada anteriormente(imagemWordpressRDS).
- Escolha o tipo de instancia "t2.micro(1 vCPUs, 1 GiB, Somente EBS)".
- Mantenha as demais configurações pré-definidas, em Grupos de segurança selecione o que foi criado e anexado anteriormente a instancia.
- Escolha um par de chaves, o mesmo anexado a instancia ao criá-la.
- Marque a caixinha: "Confirmo que tenho acesso ao arquivo de chave privada selecionado (chavePPKatividadeDocker.pem) e que, sem esse arquivo, não poderei fazer login na minha instância".
- Clique em "criar configuração de execução".
- Voltando ao processo de criação do Auto Scaling Group recarregue as opções de configuração de execução e selecione a que acabamos de criar(ModeloExecWordPress).
- Clique em "próximo" no canto inferior direito.
  
### **Etapa 2** - Escolher as opções de execução da instancia
- Mantenha a VPC Default já pré-definida e selecione as zonas de disponibilidade em que o grupo do Auto Scaling pode usar na VPC escolhida.(us-east-1c e us-east-1d).
- Clique em "próximo" no canto inferior direito.
  
### **Etapa 3** - Configurar opções avançadas
- Em balanceamento de carga selecione "anexar a um novo balanceador de carga" assim criaremos o Load Balancer juntamente do Auto Scaling.
- Em tipo de balanceador de carga selecione "Application Load Balancer".
- Dê uma nome para o mesmo(LoadBalancerWordPress) e selecione como esquema "Internet-facing". Observe que o novo balanceador de carga será criado usando as mesmas seleções de VPC e zona de disponibilidade que seu grupo do Auto Scaling.
- Em Zonas de disponibilidade e sub-redes já vem pré-selecionadas as duas zonas disponibilizadas anteriormente para o Auto Scaling, nelas que serão criadas as novas instancias.
- Abaixo, na parte de Listeners e roteamento é necessário selecionar um grupo de destino, clique na opçaõ para criar um novo, ele automaticamente dá o nome baseado no Load Balancer.
- Mantenha o restante das configurações pré-definidas e clique em "próximo" no canto inferior direito.
  
### **Etapa 4** - Configurar políticas de escalabilidade e tamanho do grupo
- Tamanho do grupo, aqui vamos especificar o tamanho do grupo do Auto Scaling alterando a capacidade desejada. Você também pode especificar os limites de capacidade mínima e máxima. Sua capacidade desejada deve estar dentro do intervalo dos limites. Neste caso vamos configurar de acordo com o que a atividade pede(Capacidade desejada: 2, Capacidade mínima: 2, Capacidade máxima: 2).
- Mantenha o restante das configurações pré-definidas pela aws e clique em "próximo" no canto inferior direito.
  
### **Etapa 5** - Adicionar Notificações
- Não vamos nenhuma configuração de notificações no momento, clique em "próximo" novamente.
  
### **Etapa 6** - Adicionar Etiquetas
- Adicione uma etiqueta "Name" com valor "PBsenac-WordPress" para as novas intancias subirem já nomeadas, facilitando a identificação.
- Clique em "próximo" no canto inferior direito para ir para a Etapa 7 de Análise.
- Revise e clique em "Criar grupo de Auto Scaling"
<br>
## 📎 Referências
[MEditor.md](https://pandao.github.io/editor.md/index.html)<br>
[Servidor de Arquivos NFS](https://debian-handbook.info/browse/pt-BR/stable/sect.nfs-file-server.html)<br>
[AWS Elastic File System](https://aws.amazon.com/pt/efs/)