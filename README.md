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
