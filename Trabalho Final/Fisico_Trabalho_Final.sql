--TODOS OS ENUM

create type tipo_ala as enum (
'uti',
'enfermaria',
'pediatria'
);

create type status_leito as enum(
'ocupado',
'livre',
'em manutencao'
);

create type turno_enfermeira as enum(
'manha',
'tarde',
'noite'
);

create type tipo_atendimento as enum(
'consulta',
'emergencia',
'revisao'
);

create type status_atendimento as enum(
'realizado',
'cancelado',
'agendado'
);

create type status_fatura as enum(
'pendente',
'pago',
'cancelado',
'em analise'
);

create type forma_pagamento as enum(  
'dinheiro',
'cartao',
'pix'
);

create type cobertura_plano as enum(
'regional',
'nacional'
);

create type resultado_exame as enum(
'normal',
'alterado',
'critico'
);

create type tipo_exame as enum(
'sangue',
'urina',
'fezes',
'imagem'
);

create type tipo_laboratorio as enum(
'interno',
'externo'
);

create type tipo_especialidade as enum(
	'cardiologista',
	'pediatria',
	'clinico geral'
);

-- TODAS AS TABELAS

create table hospital (
id_hospital serial primary key,
nome varchar(40) not null,
cnpj char(14) unique
);

create table enfermeira (
id_enfermeira serial primary key,
nome varchar(50),
cre char(9),
turno turno_enfermeira,
id_enfermeira_chefe int,
foreign key(id_enfermeira_chefe) references enfermeira(id_enfermeira)
on delete set null on update no action 
);

create table ala (
id_ala serial primary key,
tipo tipo_ala,
leitos_disponiveis int,
fk_id_hospital int,
fk_id_enfermeira int,
foreign key(fk_id_hospital) references hospital(id_hospital)
on delete cascade on update no action, 
foreign key(fk_id_enfermeira) references enfermeira(id_enfermeira)
on delete set null on update no action
);

create table leito (
id_leito serial primary key,
status status_leito,
fk_id_ala int,
foreign key(fk_id_ala) references ala(id_ala)
);

create table telefone (
id_telefone serial primary key,
telefone_fixo char(11),
telefone_celular char(11)
);

create table plano_de_saude (
id_plano_de_saude serial primary key,
nome varchar(50),
cobertura cobertura_plano,
fk_id_telefone int,
foreign key(fk_id_telefone) references telefone(id_telefone)
);

create table credenciamento(
id_credenciamento serial primary key,
data date not null,
fk_id_hospital int,
fk_id_plano_de_saude int,
foreign key(fk_id_hospital) references hospital(id_hospital)
on delete cascade on update no action,
foreign key(fk_id_plano_de_saude) references plano_de_saude(id_plano_de_saude)
on delete cascade on update no action
);

create table endereco(
	id_endereco serial primary key,
	cep int unique not null,
	rua varchar(100) not null,
	bairro varchar(100) not null,
	cidade varchar(100) not null,
	estado varchar(100) not null,
	numero_casa int not null
);

create table paciente(
	id_paciente serial primary key,
	nome varchar(60),
	cpf char(11) unique,
	fk_endereco int default null,
	fk_id_telefone int default null,
	data_nascimento date,
	foreign key(fk_id_telefone) references telefone(id_telefone)
	on delete no action
	on update no action,
	foreign key(fk_endereco) references endereco(id_endereco)
);

-- CÓDIGO ANTERIOR
/*
	create table internacao(
		id_internacao serial primary key,
		data_entrada date,
		data_saida date check(data_saida > data_entrada),
		status boolean generated always as
						( case 
					when current_date > data_saida then true
					else false
		   			end
		   				) stored,
			fk_id_paciente int,
			fk_id_leito int,
			foreign key(fk_id_paciente) references paciente(id_paciente)
			on delete set null
			on update no action,
			foreign key(fk_id_leito) references leito(id_leito)
			on delete set null
			on update no action
);*/


create table internacao(
		id_internacao serial primary key,
		data_entrada date,
		data_saida date check(data_saida > data_entrada),
		status boolean,
		fk_id_paciente int,
		fk_id_leito int,
		foreign key(fk_id_paciente) references paciente(id_paciente)
		on delete set null
		on update no action,
		foreign key(fk_id_leito) references leito(id_leito)
		on delete set null
		on update no action
);

create table medico(
	id_medico serial primary key,
	crm char(8) unique not null,
	nome varchar(60) not null,
	especialidade tipo_especialidade not null,
	fk_telefone int,
	foreign key(fk_telefone) references telefone(id_telefone)
);

create table pesquisa_satisfacao(
	id_pesquisa serial primary key,
	data_resposta date,
	nota_geral int check(nota_geral between 1 and 5),
	comentario text,
	recomendaria boolean,
	tempo_espera_avaliacao int check(tempo_espera_avaliacao between 1 and 5)
);

create table atendimento(
	id_atendimento serial primary key,
	data_atendimento timestamp,
	tipo tipo_atendimento,
	observacoes text,
	status status_atendimento,
	fk_id_medico int,
	fk_id_paciente int,
	fk_id_pesquisa int,
	foreign key(fk_id_medico) references medico(id_medico)
	on delete cascade
	on update no action,
	foreign key(fk_id_paciente) references paciente(id_paciente)
	on delete cascade
	on update no action,
	foreign key (fk_id_pesquisa) references pesquisa_satisfacao(id_pesquisa)
	on delete cascade
	on update no action
);

create table prescricao(
	id_prescricao serial primary key,
	data_prescricao date,
	fk_id_atendimento int,
	foreign key(fk_id_atendimento) references atendimento(id_atendimento)
	on update no action
	on delete cascade
);

create table medicamento( 
	id_medicamento serial primary key, 
	nome varchar(50),
	laboratorio varchar(50)
);

create table prescricao_medicamento( 
	id_prescricao_medicamento serial primary key,
	dosagem numeric,
	quantidade int,
	fk_id_prescricao int,
	fk_id_medicamento int,
	foreign key(fk_id_prescricao) references prescricao(id_prescricao)
	on delete cascade
	on update no action,
	foreign key(fk_id_medicamento) references medicamento(id_medicamento)
	on delete cascade
	on update no action
);

create table exame( 
	id_exame serial primary key,
	tipo tipo_exame,
	data_solicitacao date,
	descricao_detalhada text,
	fk_id_atendimento int,
	foreign key(fk_id_atendimento) references atendimento(id_atendimento)
	on delete cascade
	on update no action
	);

create table laudo( 
	id_laudo serial primary key,
	resultado resultado_exame, 
	data_resultado date, 
	fk_id_exame int,
	foreign key(fk_id_exame) references exame(id_exame)
	on delete cascade
	on update no action 
);
 
create table laboratorio(
	id_laboratorio serial primary key, 
	tipo tipo_laboratorio
);

create table exame_laboratorio( 
	id_exame_laboratorio serial primary key,
	custo numeric,
	fk_id_laboratorio int,
	fk_id_exame int,
	foreign key(fk_id_laboratorio) references laboratorio(id_laboratorio)
	on delete cascade
	on update no action,
	foreign key(fk_id_exame) references exame(id_exame)
	on delete cascade 
	on update no action	
);

create table fatura(  
	id_fatura serial primary key, 
	valor_fatura numeric, 
	status status_fatura,
	forma_pagamento forma_pagamento,
	data_emissao date,
	data_vencimento date,
	fk_id_plano int,
	fk_id_atendimento int,
	foreign key (fk_id_plano) references plano_de_saude(id_plano_de_saude)
	on delete cascade
	on update no action,
	foreign key (fk_id_atendimento) references atendimento(id_atendimento)
	on delete cascade
	on update no action
);


































