# ⏰ Projeto de Arquitetura de Computadores — Alarme Digital

## 👨‍💻 Autores
Wallace dos Santos Izidoro — RA: 22.123.104-6

Pedro Henrique da F. do Nascimento — RA: 22.123.099-8

## 📌 Descrição do Projeto
Este projeto tem como objetivo o desenvolvimento de um Relógio Digital com funcionalidade de Despertador, utilizando o simulador edSim51, que emula o funcionamento do microcontrolador Intel 8051.

O sistema é capaz de exibir a hora atual em um display LCD 16x2 e permite ao usuário configurar um horário de alarme por meio de um teclado matricial 4x3. Quando o relógio atinge o horário configurado, o sistema aciona uma notificação na tela.

Além disso, foi implementada uma função de pausa (snooze), permitindo ao usuário adiar o alarme por um tempo determinado.

## ⚙️ Funcionalidades Implementadas
⌨️ Leitura de entradas via teclado matricial 4x3
Permite ao usuário digitar horas e minutos para configurar o alarme.

⏲️ Exibição do horário atual em tempo real no display LCD 16x2
A hora é atualizada constantemente no display, com formatação HH:MM.

🔔 Configuração e ativação de alarme
O sistema permite que o usuário defina um horário específico para o alarme disparar.

💤 Função de Pausa (Snooze)
Ao tocar o alarme, o usuário pode optar por pausá-lo temporariamente. Após o tempo de snooze (pré-definido), o alarme será reativado automaticamente.

🖥️ Interface intuitiva
A interação entre teclado, display e sistema de alarme é clara e de fácil entendimento, ideal para simulação educacional.

## 🧰 Tecnologias e Componentes Utilizados
Simulador: edSim51

Linguagem de Programação: Assembly para o microcontrolador 8051

Microcontrolador Simulado: Intel 8051

Display: LCD 16x2 (modo de escrita direta em memória)

Entrada de Dados: Teclado Matricial 4x3

Temporizadores Internos: Utilização de Timer 0 ou Timer 1 do 8051 para contagem do tempo

🛠️ Estrutura do Projeto
O código foi estruturado modularmente para facilitar leitura e manutenção:

## Inicialização do sistema
Configuração do LCD, timers e variáveis globais.

Leitura do teclado matricial
Detecção de teclas pressionadas com debounce e mapeamento de caracteres.

Configuração da hora e do alarme
Estado de configuração acionado por tecla específica.

Contador de tempo (relógio)
Atualização da hora a cada ciclo completo do timer.

Verificação do alarme
Comparação entre a hora atual e a hora configurada para alarme.

Ação do alarme e pausa (snooze)
Exibição de mensagem e contagem de tempo para reativação do alerta.

## ✅ Testes Realizados
Testes unitários de entrada via teclado

Simulação do incremento do tempo real

Verificação da ativação do alarme em diferentes horários

Testes da função de snooze com tempos variados

## 📌 Conclusão
O projeto demonstrou com sucesso a aplicação prática dos conceitos estudados em arquitetura de computadores e programação em baixo nível com Assembly. A integração entre periféricos (teclado, display e timers) permitiu simular um sistema embarcado funcional e interativo.

A adição da funcionalidade de pausa do despertador trouxe maior realismo à simulação, agregando valor ao projeto e explorando ainda mais os recursos do microcontrolador 8051.

## Fluxograma do projeto
![Fluxograma do projeto](imagens/mermaid-projeto-arquitetura.png)

## Imagens do funcionamento do projeto

### Mensagem de boas vindas
![Início](imagens/mensagem-iniciando.png)

### Início
![Início](imagens/inicio.png)

### Mensagem do despertador
![Acorda!](imagens/mensagem-acorda.png)
