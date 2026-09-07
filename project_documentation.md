# Documentação do Projeto Ivalid

## 1. Visão Geral
O **Ivalid** é um aplicativo Flutter focado no combate ao desperdício de alimentos. A plataforma conecta usuários a produtos próximos do vencimento com descontos agressivos (abaixo de 10 dias) e facilita a doação de alimentos para ONGs parceiras, integrando gamificação e responsabilidade social.

---

## 2. Stack Tecnológica
*   **Framework**: Flutter (Dart)
*   **Backend**: Firebase
    *   **Authentication**: Gestão de usuários.
    *   **Cloud Firestore**: Banco de dados NoSQL em tempo real.
    *   **Storage**: Armazenamento de imagens de produtos.
*   **Gerenciamento de Estado**: Provider (ChangeNotifier)
*   **Navegação**: GoRouter & Custom BottomNavigationBar (Animated)
*   **Design System**: Customizado (AppColors, Google Fonts: Inter)
*   **Integrações Externas**:
    *   `cached_network_image`: Cache eficiente de imagens.
    *   `shared_preferences`: Persistência local (ex: flags de onboarding).
    *   `intl`: Formatação de moedas e datas (pt-BR).

---

## 3. Arquitetura e Estrutura de Pastas
O projeto segue uma organização baseada em **Features**, facilitando a escalabilidade e manutenção.

```
lib/
├── core/                  # Recursos compartilhados e fundamentais
│   └── theme/             # Design System (Cores, Fontes, Temas)
├── features/              # Módulos funcionais do app
│   ├── auth/              # Login, Cadastro e Recuperação
│   ├── home/              # Listagem, Filtros e Detalhes de Produto
│   ├── cart/              # Carrinho, Checkout e Cashback
│   ├── donation/          # Fluxo social e ONGs
│   ├── flash/             # Ofertas urgentes (<10 dias)
│   ├── orders/            # Histórico e Status de Pedidos
│   └── profile/           # Perfil e Níveis de Fidelidade
├── firebase_options.dart  # Configuração do Firebase
├── main.dart              # Ponto de entrada e MultiProvider
└── main_page.dart         # Navegação persistente (BottomNav)
```

---

## 4. Módulos e Funcionalidades Core

### 4.1 Autenticação (`auth`)
*   Login e Registro integrados ao Firebase Auth.
*   `AuthWrapper`: Gerencia o estado da sessão (Login vs Home).

### 4.2 Home & Descoberta (`home`)
*   **Categorias**: Filtragem dinâmica de produtos.
*   **Ordenação**: Por preço, distância, desconto e vencimento.
*   **Busca**: Filtro em tempo real por nome.
*   **Detalhes do Produto**: Visualização premium, informações de loja e seletor de quantidade.

### 4.3 Doação Social (`donation`)
*   **Contexto de Doação**: Produtos comprados nesta aba são destinados diretamente a ONGs.
*   **Impact Stats**: Visualização do impacto gerado pelo usuário.
*   **Cashback Social**: Incentivo de até 5% para compras futuras ao realizar doações.

### 4.4 Ofertas Flash (`flash`)
*   Filtro automático para produtos com vencimento crítico (< 10 dias).
*   Cards com indicadores de urgência visual.

### 4.5 Carrinho & Checkout (`cart`)
*   Diferenciação entre itens para consumo e itens para doação.
*   Cálculo automático de subtotal e taxas.
*   Sistema de gamificação aplicado no fechamento do pedido.

### 4.6 Pedidos (`orders`)
*   Histórico detalhado com status (Pendente, Em Preparação, Entregue).
*   Visualização expandida de itens por pedido.
*   Summary Stats: Total gasto e pedidos realizados.

### 4.7 Perfil & Fidelidade (`profile`)
*   **Níveis de Fidelidade**: Bronze, Prata e Ouro baseados no número de doações.
*   **Gestão de Endereço**: Integração ViaCEP para preenchimento automático.
*   **Ivalid Pago**: Central de pagamentos e saldos.

---

## 5. Design System
O aplicativo utiliza uma estética **High-End** com os seguintes princípios:
*   **Cores**: Vermelho primário (`#E63946`) para urgência e confiança.
*   **Tipografia**: *Inter* para legibilidade profissional.
*   **Componentes**:
    *   **Sombras**: Uso de `BoxShadow` suaves para profundidade.
    *   **Animações**: Micro-interações na BottomNav e transições de cards.
    *   **Status**: Badges coloridos para estados de pedido e urgência.

---

## 6. Fluxo de Dados
1.  **Providers** (`ChangeNotifier`) escutam o Firestore.
2.  **UI** reage aos `notifyListeners()` dos Providers.
3.  **Ações do Usuário** disparam chamadas assíncronas no Firebase através dos Providers.
4.  **Sessão** é mantida pelo `FirebaseAuth` e verificada no `AuthWrapper`.

---

## 7. Configuração e Build
1.  Certifique-se de ter o Flutter SDK instalado.
2.  Execute `flutter pub get` para instalar dependências.
3.  Configure o Firebase para sua plataforma (Android/iOS/Windows).
4.  Rode o comando `flutter run` no dispositivo desejado.
