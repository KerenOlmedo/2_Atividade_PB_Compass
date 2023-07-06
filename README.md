<h1 align="center"> 2_Atividade_PB_Compass </h1>
<h3 align="center"> Prática Docker/AWS utilizando RDS, EFS, AutoScaling e LoadBalancer</h3>


<p align="center">
  <a href="#-Objetivo">Objetivo</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Descrição-dos-requisitos">Descrição dos requisitos</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Pontos-de-atenção">Pontos de atenção</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Instruções-de-Execução">Instruções de Execução</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-Referências">Referências</a>
</p>


## 🚀 Objetivo

Contruir e documentar o processo de criação e configuração da seguinte arquitetura:

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
### Subir instância EC2 com par de chaves PPK
- Acessar a AWS na pagina do serviço EC2, e clicar em "instancias" no menu lateral esquerdo.
- Clicar em "executar instâncias" na parte superior esquerda da tela.
- Abaixo do campo de inserir nome clicar em "adicionar mais tags".
- Crie e insira o valor para as chaves: Name, Project e CostCenter, selecionando "intancias", "volume" e "interface de rede" como tipos de recurso e adicionando os valores de sua preferencia.
- Abaixo selecione também a AMI Amazon Linux 2(HVM) SSD Volume Type.
- Selecionar como tipo de intância a família t3.small.
- Em Par de chaves login clique em "criar novo par de chaves".
- Insira o nome do par de chaves, tipo RSA, formato .ppk e clique em "criar par de chaves".
- Em configurações de rede, selecione criar grupo de segurança e permitir todos tráfegos(SSH).
- Configure o armazenamento com 16GiB, volume raiz gp2.
- Clique em executar instância.
![Instancia modelo](./images/Instancia%20modelo.PNG)

### Editar grupo de segurança liberando as portas de comunicação para acesso
- Na pagina do serviço EC2, no menu lateral esquerdo ir em "Rede e Segurança" e clicar em "Security groups".
- Selecionar o grupo criado anteriormente junto com a instancia.
- Clicar em "Regras de entrada" e do lado esquerdo da tela em "Editar regras de entrada".
- Defina as regras como na tabela abaixo:

    Tipo | Protocolo | Intervalo de portas | Origem | Descrição
    ---|---|---|---|---
    SSH | TCP | 22 | 0.0.0.0/0 | SSH
    TCP personalizado | TCP | 80 | 0.0.0.0/0 | HTTP
    TCP personalizado | TCP | 2049 | 0.0.0.0/0 | NFS
    MYSQL/Aurora | TCP | 3306 | 0.0.0.0/0 | RDS

- Clicar em "Salvar regras".

### Servidor de arquivos EFS
Antes de começarmos as configurações via chave PPK(Putty) para EFS, navegue no serviço EC2 da AWS em Security groups.
- Clique em criar grupo de segurança, este será utilizado para segurança de rede do EFS.
- Depois de atribuir um nome(EFS-acesso), adicione como regra de entrada o NFS com origem para o grupo de segurança criado e anexado anteriormente junto da instancia.
Deverá ficar assim:
    Tipo | Protocolo | Intervalo de portas | Origem | Descrição
    ---|---|---|---|---
    NFS | TCP | 2049 | sg-0e0fe595c74f876a6 | NFS

- Clique em criar grupo de segurança para finalizar.

### Criando Elastic File System
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
### Acessando sua EC2 através do Putty com chave PPK

### Montando sistema de arquivos do EFS
- Com o acesso via PUTTY, instale o pacote necessário através do comando:
```
sudo yum install nfs-utils
```
Ao instalar o "nfs-utils", você estará habilitando seu sistema para usar o NFS, este é um protocolo que permite compartilhar diretórios e arquivos entre sistemas operacionais em uma rede.
- Depois disso é necessário criar um diretório de arquivos para o EFS no diretótio de montagem, através do comando:
```
sudo mkdir /mnt/efs/wordpress
```
Obs: Como nossa aplicação utilizará o EFS para salvar estáticos do WordPress já estamos criando uma pasta para o mesmo dentro do diretório, por critério de organização.

Podemos montar o sistema de arquivos de forma manual e de forma automática.
#### --> Manual 
Nessa forma será necessário montar sempre que a maquina for iniciada, utilizando o comando abaixo(o mesmo copiado do sistemas de arquivos anteriormente):
```
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs- fs-07d84686cb6d691f7.efs.us-east-1.amazonaws.com:/ /mnt/efs
```
Certifique-se de substituir "/mnt/efs" pelo caminho real do seu diretório e "fs-07d84686cb6d691f7.efs.us-east-1.amazonaws.com" pelo ID e região do seu sistema de arquivos.

- Para verificar se o sistema de arquivos do EFS está montado no diretório /mnt/efs, você pode usar o seguinte comando:
```
df -hT | grep /mnt/efs
```
Este comando lista todos os sistemas de arquivos montados no sistema e filtra apenas as linhas que contêm o diretório /mnt/efs. Se o EFS estiver montado corretamente, você verá uma linha de saída que mostra o sistema de arquivos do EFS e seus detalhes.

#### --> Forma Automática(recomendada)


- Para configurar a montagem do sistema de arquivos de forma automática é necessário editar o arquivo "etc/fstab", edite o mesmo através do comando:
```
sudo nano /etc/fstab
```
- Adicione a seguinte linha no final do arquivo:
```
fs-07d84686cb6d691f7.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0
```
Novamente, substitua "fs-07d84686cb6d691f7.efs.us-east-1.amazonaws.com" pelo ID do sistema de arquivos do seu EFS.
- Salve e feche o arquivo.
- Execute o comando abaixo para montar o compartilhamento NFS sempre que necessário novamente:
```
sudo mount -a
```
- Em seguida execute o seguinte comando para reiniciar a instância:
```
sudo reboot
```
Após a reinicialização, o sistema de arquivos do EFS estará montado no diretório /mnt/efs e estará disponível para uso na instância.
Para verificar se o sistema de arquivos do EFS está realmente montado, execute o comando:
```
df -hT | grep /mnt/efs
```
Este comando lista todos os sistemas de arquivos montados no sistema e filtra apenas as linhas que contêm o diretório /mnt/efs. Se o EFS estiver montado corretamente, você verá uma linha de saída que mostra o sistema de arquivos do EFS e seus detalhes.

### Criando um Script de start instance para instalação do Docker e Docker-compose
- No local de sua preferencia crie um arquivo com extensão "sh" através do editor de texto nano ou outro de sua preferencia através do comando:
```
sudo nano dockerinstall.sh
```
- Coloque o seguinte conteúdo no script:
```
sudo yum update -y

sudo amazon-linux-extras install docker -y

sudo service docker start

sudo usermod -a -G docker $(ec2-user)

sudo chkconfig docker on

docker version
```
- Feche o mesmo pressionando "ctrl + x" e "y" para salvar.
- Esse script realiza as seguintes ações:
1. Atualiza o sistema usando o comando yum update.
2. Instala o Docker usando o comando amazon-linux-extras install docker.
3. Inicia o serviço do Docker usando o comando service docker start.
4. Adiciona o usuário atual ao grupo "docker" para evitar o uso de "sudo" para comandos do Docker.
5. Configura o Docker para iniciar automaticamente na inicialização do sistema usando o comando chkconfig.
6. Verifica a versão do Docker instalada usando o comando docker version.

- Depois de criar o arquivo "dockerinstall.sh" é preciso dar permissão de execução ao mesmo usando o comando:
```
sudo chmod +x dockerinstall.sh
```
- Certifique-se de executar o script com privilégios adequados, como usar a conta root ou usar o comando sudo para executar os comandos necessários.
- Depois para executar o script estando no diretório em que ele pertence utilize o comando:
```
./dockerinstall.sh
```
- Para executá-lo fora do diretório em que ele pertence é necessário utilizar o caminho completo como no exemplo de comando abaixo:
```
/home/ec2-user/dockerinstall.sh
```
## Criando RDS(MySQL)
- Acesse o serviço RDS na sua conta AWS, no canto lateral esquerdo clique em "Banco de dados".
- Clique no botão laranja no canto superior direito em "Criar banco de dados".
- Selecione o métode de "criação fácil "e "MySQL" como banco de configuração.
![tipo de banco RDS](./images/tipo%20de%20banco%20RDS.PNG)
- Selecione também o "nível gratuito" e preencha as credenciais do banco(não esqueça de gravá-las)
![credenciaisRDS](./images/credenciaisRDS.PNG)
- Por último clique em "criar banco de dados" no canto inferior da tela.
- Aguarde a criação, isso pode levar alguns minutos.

### Criando um arquivo Docker-compose

- Crie um arquivo "docker-compose.yml" utilizando a linguagem YAML através do comando:
```
sudo nano docker-compose.yml
```
- No arquivo cole o conteúdo abaixo, nele vamos estar setando as variáveis necessárias para subir um contêiner com imagem do WordPress e com os dados do banco MySQL(RDS) criado anteriormente através da AWS.

```
version: '3'
services:

  wordpress:
    image: wordpress:latest
    volumes:
      - wp_data:/var/www/html
    restart: always
    ports:
      - 8080:80
    environment:
      WORDPRESS_DB_HOST: databasepb.czuctyrea21y.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: adminPB
      WORDPRESS_DB_PASSWORD: estagioCompass
      WORDPRESS_DB_NAME: databasepb
volumes:
  wp_data:
```
- Para executar o arquivo e subir o container com Wordpress conectado ao banco MySQL execute o comando:
```
docker-compose up -d
```
Variáveis utilizadas no arquivo docker-compose:
- MYSQL_ROOT_PASSWORD: Define a senha do usuário root do MySQL.
- MYSQL_DATABASE: Especifica o nome do banco de dados(RDS) para o WordPress.
- MYSQL_USER: Define o nome de usuário do MySQL para o WordPress.
- MYSQL_PASSWORD: Define a senha do usuário do MySQL para o WordPress.
- WORDPRESS_DB_HOST: Especifica o nome do serviço do banco de dados (db) para o WordPress se conectar.
- WORDPRESS_DB_USER: Especifica o nome de usuário do banco de dados para o WordPress.
- WORDPRESS_DB_PASSWORD: Define a senha do usuário do banco de dados para o WordPress.
- ORDPRESS_DB_NAME: Especifica o nome do banco de dados do WordPress.

- O WordPress estará acessível em http://localhost:8080 (ou em outra porta se você alterou a configuração do arquivo), substitua "localhost" pelo endereço na sua instancia EC2 e lembre-se de que é necessário que a porta 8080 esteja liberada nas regras de entrada do grupo de segurança em que a mesma pertence.

## Testando a conexão com o banco MySQL (RDS)
- Acesse o container criado anteriormente através do seu ID e com o comando:
```
docker exec -it <ID_do_contêiner_wordpress> /bin/bash
```
- Depois de acessar o terminal do container tente executar o seguinte comando para testar a conexão com o RDS:
```
nc -vz <nome_do_host_do_banco_de_dados> 3306
```
 Substitua <nome_do_host_do_banco_de_dados> pelo endpoint do seu RDS lá da AWS. O comando deve retornar algo como esta mensagem de secessed:
  FOTO
- Caso dê algum erro no comando é porque o pacote netcat não vem instalado como padrão do container. Execute os dois comandos abaixo e tente novamente.
```
apt-get update
```
```
apt-get install -y netcat
```
<br>
## 📎 Referências
[MEditor.md](https://pandao.github.io/editor.md/index.html)<br>
[Servidor de Arquivos NFS](https://debian-handbook.info/browse/pt-BR/stable/sect.nfs-file-server.html)<br>
[AWS Elastic File System](https://aws.amazon.com/pt/efs/)