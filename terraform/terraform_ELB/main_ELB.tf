#CRIAÇÃO ELASTC LOAD BALANCE ELB
resource "aws_lb" "internet_facing_sg" {   #AQUI VOCÊ DEFINE O RECURSO E O NOME DO ELB
  name               = "internet-facing"  #AQUI VOCÊ DEFINE O TAG NAME DO RECURSO
  internal           = false              #AQUI DEFINIMOS QUE NÃO SERÁ DE TRÁFEGO INTERNO
  load_balancer_type = "application"      #AQUI VOCÊ DEFINE O TIPO DE ELB QUE SERÁ CRIADO
  security_groups   = [aws_security_group.internet_facing_sg.id]    #AQUI VOCÊ ASSOCIA O SG CRIADO ACIMA AO ELB

  enable_deletion_protection = false  # ESSE ITEM HABILITA A PROTEÇÃO CONTRA EXCLUSÃO ACIDENTAL

  enable_http2       = true   #AQUI VOCÊ HABILITA O PROTOCOLO HTTP2
  enable_cross_zone_load_balancing = true #AQUI VOCÊ HABILITA A ALTA DISPONIBILIDADE ENTRE ZONAS AWS

  subnets = [aws_subnet.sub_ext_prod_a.id, aws_subnet.sub_ext_prod_b.id]  #AQUI VOCÊ ADICIONA SUAS SUB REDES ZONAS A E B. COMO É PARA A INTERNET, PRECISA ADICIONAR AS DUAS SUBREDES PÚBLICAS.
}