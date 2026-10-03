# Ivalid

Aplicativo para combate ao desperdício de alimentos.

Centro Universitário Alfredo Nasser · Engenharia de Software · Projeto de Desenvolvimento de Software (PDS) · Goiânia, 2026

O Ivalid liga o consumidor a produtos perto do vencimento, com desconto conforme os dias que faltam para a validade. Dá para comprar para consumo próprio ou doar a ONGs parceiras, e o aplicativo mostra o impacto dessa escolha.

A especificação do sistema está em [docs/ERS_Ivalid.html](docs/ERS_Ivalid.html).

## Autores

| Nome | Papel |
| --- | --- |
| Maria Eduarda Silva Viana | Analista de requisitos / desenvolvimento |
| Lucas Freitas | Analista de requisitos / desenvolvimento |
| David Oliveira Silva | Analista de requisitos / desenvolvimento |
| Ricardo Gabriel | Analista de requisitos / desenvolvimento |

## Como rodar

É preciso ter o [Flutter](https://docs.flutter.dev/get-started/install) instalado e um emulador ou celular Android.

```bash
flutter pub get
flutter run
```

O arquivo `android/app/google-services.json` já está no projeto e é o que conecta o app ao Firebase. Sem ele, login e catálogo não abrem.

Para apresentar o pagamento sem cobrança real:

```bash
flutter run --dart-define=PAYMENT_DEMO=true
```

Os testes automatizados:

```bash
flutter test
```

## Navegação

Quem não está logado fica na tela de login. Depois do login, a barra de baixo tem cinco abas:

| Aba | O que mostra |
| --- | --- |
| Início | Catálogo, busca, categorias e ofertas perto do vencimento |
| Doação | Itens para doar a ONGs parceiras |
| Flash | Produtos com até 10 dias para vencer |
| Pedidos | Histórico de compras |
| Perfil | Conta, fidelidade, Ivalid Pago, configurações e saída |

Carrinho, detalhes do produto, checkout e configurações abrem por cima dessas abas.

## Estrutura

```text
lib/
  core/            tema e widgets usados em várias telas
  features/
    auth/          login e cadastro
    home/          catálogo e detalhes do produto
    donation/      doação
    flash/         ofertas urgentes
    cart/          carrinho e checkout
    orders/        pedidos
    payment/       pagamento
    impact/        calculadora de impacto
    profile/       perfil, fidelidade e Ivalid Pago
    settings/      conta, segurança, tema e ajuda
docs/              especificação e relatório de segurança
test/              testes automatizados
```
