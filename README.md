# terraform-website
Exemplo de configuração de um website estático com EC2 usando Terraform.

## Passos manuais
Criar uma chave de acesso em IAM e substituir em `access_key` e `secret_key` no `provider`.

Criar um key-pair com o nome `kp_terraform-website`, para acesso SSH na instância EC2.

## Aplicação
Iniciar:
```bash
terraform init
```

Conferir:
```bash
terraform plan
```

Aplicar:
```bash
terraform apply
```

Destruir:
```bash
terraform destroy
```

## Vendo o resultado
Encontrar o IP e o DNS públicos disponibilizados para a instância. Eles será exibido ao final do `apply`. Caso não seja, use:

```bash
terraform output
```

ou

```bash
terraform state show aws_eip.eip-production
```

Acessar pelo navegador (neste exemplo, somente via HTTP).

## Alterando o conteúdo da instância

Você pode alterar o conteúdo a ser baixado via `git clone` através da variável `repo_url` no arquivo `terraform.tfvars`. Teste com algum dos exemplos ou use qualquer repositório com arquivos estáticos.

Caso já tenha criado, você pode destruir somente a instância EC2:

```bash
terraform destroy -target aws_instance.ec2-production
```

E recriar o recurso:

```bash
terraform apply -target aws_instance.ec2-production
```
