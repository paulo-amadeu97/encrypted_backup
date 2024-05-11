# Script de Backup Seguro

Este é um script em bash desenvolvido por Paulo Mendonça para criar backups personalizados de forma segura, utilizando criptografia OpenSSL. Ele também permite descriptografar arquivos de backup utilizando uma senha fornecida pelo usuário.

## Como usar

Execute o script da seguinte maneira:

$ ./script.sh [opções] [argumentos]


### Opções:

- **[-d] diretório:** Define o diretório padrão do backup. Se não for definido, será utilizado o diretório home do usuário como padrão.

- **[-o] diretório:** Define o diretório destino do arquivo de backup criptografado. Se não for definido, será utilizado o diretório atual do bash.

- **[{arquivo}.enc]:** Descriptografa um arquivo `.enc` através da senha fornecida pelo usuário.

## Autor

- **Nome:** Paulo Mendonça
- **Descrição:** O script foi desenvolvido com o intuito de facilitar a criação de backups seguros.
- **Contato:** [paulo.amadeu18@gmail.com](mailto:paulo.amadeu18@gmail.com) | [paulo.mendonca@sou.ufmt.br](mailto:paulo.mendonca@sou.ufmt.br)

---

Este script oferece uma maneira conveniente e segura de fazer backups e descriptografar arquivos de backup. Certifique-se de fornecer as opções corretas para obter os resultados desejados.
