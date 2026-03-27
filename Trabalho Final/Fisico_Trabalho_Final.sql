---------------------------------------------CREATS DDL-----------------------------------------------------------------------


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

---------------------------------------------INSERTS DML-----------------------------------------------------------------------

-- HOSPITAL
INSERT INTO hospital (nome, cnpj) VALUES 
('Hospital Santa Luzia', '12345678000101'), ('Hospital Geral Norte', '23456789000102'),
('Maternidade Vida', '34567890000103'), ('Hospital Infantil Day', '45678901000104'),
('Hospital do Coração', '56789012000105'), ('Clínica São José', '67890123000106'),
('Hospital Metropolitano', '78901234000107'), ('Hospital das Clínicas', '89012345000108'),
('Pronto Socorro Central', '90123456000109'), ('Hospital de Trauma', '01234567000110');

-- TELEFONE
INSERT INTO telefone (telefone_fixo, telefone_celular) VALUES 
('1133445566', '11988776655'), ('2133445566', '21988776655'), ('3133445566', '31988776655'),
('4133445566', '41988776655'), ('5133445566', '51988776655'), ('6133445566', '61988776655'),
('7133445566', '71988776655'), ('8133445566', '81988776655'), ('9133445566', '91988776655'),
('1233445566', '12988776655');

-- ENDERECO
INSERT INTO endereco (cep, rua, bairro, cidade, estado, numero_casa) VALUES 
(12345001, 'Rua A', 'Centro', 'São Paulo', 'SP', 10), (12345002, 'Rua B', 'Jardins', 'Rio', 'RJ', 20),
(12345003, 'Rua C', 'Lapa', 'Curitiba', 'PR', 30), (12345004, 'Rua D', 'Batel', 'Porto Alegre', 'RS', 40),
(12345005, 'Rua E', 'Meireles', 'Fortaleza', 'CE', 50), (12345006, 'Rua F', 'Boa Viagem', 'Recife', 'PE', 60),
(12345007, 'Rua G', 'Savassi', 'Belo Horizonte', 'MG', 70), (12345008, 'Rua H', 'Asa Sul', 'Brasília', 'DF', 80),
(12345009, 'Rua I', 'Ponta Negra', 'Manaus', 'AM', 90), (12345010, 'Rua J', 'Graciosa', 'Vitória', 'ES', 100);

-- MEDICAMENTO
INSERT INTO medicamento (nome, laboratorio) VALUES 
('Dipirona', 'Medley'), ('Paracetamol', 'EMS'), ('Amoxicilina', 'Eurofarma'),
('Omeprazol', 'Aché'), ('Losartana', 'Neo Química'), ('Ibuprofeno', 'Bayer'),
('Sertralina', 'Libbs'), ('Metformina', 'Merck'), ('Salbutamol', 'GSK'), ('Atorvastatina', 'Pfizer');

-- LABORATORIO
INSERT INTO laboratorio (tipo) VALUES 
('interno'), ('externo'), ('interno'), ('externo'), ('interno'), 
('externo'), ('interno'), ('externo'), ('interno'), ('externo');

-- PESQUISA SATISFACAO
INSERT INTO pesquisa_satisfacao (data_resposta, nota_geral, comentario, recomendaria, tempo_espera_avaliacao) VALUES 
('2024-01-10', 5, 'Excelente atendimento', true, 5), ('2024-01-11', 4, 'Bom, mas demorado', true, 3),
('2024-01-12', 3, 'Regular', false, 2), ('2024-01-13', 5, 'Muito rápido', true, 5),
('2024-01-14', 2, 'Péssimo café', false, 1), ('2024-01-15', 4, 'Médicos atenciosos', true, 4),
('2024-01-16', 5, 'Instalações limpas', true, 5), ('2024-01-17', 3, 'Poderia melhorar', true, 3),
('2024-01-18', 4, 'Ok', true, 4), ('2024-01-19', 1, 'Não volto', false, 1);

-- ENFERMEIRA (Incluindo hierarquia: enfermeira chefe)
INSERT INTO enfermeira (nome, cre, turno, id_enfermeira_chefe) VALUES 
('Ana Silva', '123456-SP', 'manha', NULL), ('Beatriz Souza', '223456-SP', 'tarde', 1),
('Carla Dias', '323456-RJ', 'noite', 1), ('Daniela Lima', '423456-MG', 'manha', NULL),
('Elena Rosa', '523456-RS', 'tarde', 4), ('Fernanda M.', '623456-PR', 'noite', 4),
('Gisele O.', '723456-SC', 'manha', NULL), ('Heloísa P.', '823456-CE', 'tarde', 7),
('Iara Q.', '923456-PE', 'noite', 7), ('Julia R.', '023456-DF', 'manha', NULL);

-- PACIENTE
INSERT INTO paciente (nome, cpf, fk_endereco, fk_id_telefone, data_nascimento) VALUES 
('João Santos', '11122233344', 1, 1, '1985-05-20'), ('Maria Oliveira', '22233344455', 2, 2, '1990-08-15'),
('Carlos Peixoto', '33344455566', 3, 3, '1970-12-01'), ('Pedro Alvares', '44455566677', 4, 4, '2000-02-10'),
('Ana Paula', '55566677788', 5, 5, '1995-11-25'), ('Lucas Lima', '66677788899', 6, 6, '1982-04-30'),
('Marcos Castro', '77788899900', 7, 7, '1965-07-12'), ('Fernanda Costa', '88899900011', 8, 8, '2010-09-05'),
('Roberto Carlos', '99900011122', 9, 9, '1950-01-01'), ('Julia Paes', '00011122233', 10, 10, '1992-06-18');

-- MEDICO
INSERT INTO medico (crm, nome, especialidade, fk_telefone) VALUES 
('123456SP', 'Dr. Arnaldo', 'cardiologista', 1), ('223456RJ', 'Dra. Bianca', 'pediatria', 2),
('323456MG', 'Dr. Cláudio', 'clinico geral', 3), ('423456RS', 'Dra. Denise', 'cardiologista', 4),
('523456PR', 'Dr. Eduardo', 'pediatria', 5), ('623456SC', 'Dra. Fabiana', 'clinico geral', 6),
('723456CE', 'Dr. Gabriel', 'cardiologista', 7), ('823456PE', 'Dra. Helena', 'pediatria', 8),
('923456DF', 'Dr. Igor', 'clinico geral', 9), ('023456BA', 'Dra. Joana', 'cardiologista', 10);

-- PLANO DE SAUDE
INSERT INTO plano_de_saude (nome, cobertura, fk_id_telefone) VALUES 
('Unimed', 'nacional', 1), ('Bradesco', 'nacional', 2), ('Amil', 'regional', 3),
('SulAmérica', 'nacional', 4), ('Hapvida', 'regional', 5), ('Porto Seguro', 'nacional', 6),
('Intermédica', 'regional', 7), ('Golden Cross', 'regional', 8), ('Cassi', 'nacional', 9), ('Santamália', 'regional', 10);

-- ALA
INSERT INTO ala (tipo, leitos_disponiveis, fk_id_hospital, fk_id_enfermeira) VALUES 
('uti', 5, 1, 1), ('enfermaria', 10, 1, 2), ('pediatria', 8, 2, 3),
('uti', 4, 3, 4), ('enfermaria', 12, 4, 5), ('pediatria', 6, 5, 6),
('uti', 2, 6, 7), ('enfermaria', 15, 7, 8), ('pediatria', 9, 8, 9), ('uti', 10, 9, 10);

-- LEITO
INSERT INTO leito (status, fk_id_ala) VALUES 
('livre', 1), ('ocupado', 1), ('em manutencao', 2), ('livre', 2), ('ocupado', 3),
('livre', 3), ('livre', 4), ('ocupado', 5), ('em manutencao', 6), ('livre', 7);

-- CREDENCIAMENTO
INSERT INTO credenciamento (data, fk_id_hospital, fk_id_plano_de_saude) VALUES 
('2023-01-01', 1, 1), ('2023-02-01', 1, 2), ('2023-03-01', 2, 3), ('2023-04-01', 3, 4),
('2023-05-01', 4, 5), ('2023-06-01', 5, 6), ('2023-07-01', 6, 7), ('2023-08-01', 7, 8),
('2023-09-01', 8, 9), ('2023-10-01', 9, 10);

-- ATENDIMENTO
INSERT INTO atendimento (data_atendimento, tipo, observacoes, status, fk_id_medico, fk_id_paciente, fk_id_pesquisa) VALUES 
('2024-02-01 10:00:00', 'consulta', 'Dor de cabeça', 'realizado', 1, 1, 1),
('2024-02-01 11:00:00', 'emergencia', 'Febre alta', 'realizado', 2, 2, 2),
('2024-02-02 09:00:00', 'revisao', 'Pós-operatório', 'agendado', 3, 3, 3),
('2024-02-02 14:00:00', 'consulta', 'Check-up', 'realizado', 4, 4, 4),
('2024-02-03 08:30:00', 'emergencia', 'Fratura', 'cancelado', 5, 5, 5),
('2024-02-03 16:00:00', 'consulta', 'Rotina', 'realizado', 6, 6, 6),
('2024-02-04 10:00:00', 'revisao', 'Retorno', 'realizado', 7, 7, 7),
('2024-02-04 11:30:00', 'consulta', 'Exames', 'agendado', 8, 8, 8),
('2024-02-05 13:00:00', 'emergencia', 'Infecção', 'realizado', 9, 9, 9),
('2024-02-05 15:00:00', 'consulta', 'Geral', 'realizado', 10, 10, 10);

-- INTERNACAO
INSERT INTO internacao (data_entrada, data_saida, status, fk_id_paciente, fk_id_leito) VALUES 
('2024-01-01', '2024-01-05', false, 1, 1), ('2024-01-10', '2024-01-15', false, 2, 2),
('2024-02-01', '2024-02-10', true, 3, 3), ('2024-02-05', '2024-02-12', true, 4, 4),
('2024-02-10', NULL, true, 5, 5), ('2024-02-15', NULL, true, 6, 6),
('2024-03-01', '2024-03-05', false, 7, 7), ('2024-03-05', '2024-03-10', false, 8, 8),
('2024-03-10', NULL, true, 9, 9), ('2024-03-15', NULL, true, 10, 10);

-- PRESCRICAO
INSERT INTO prescricao (data_prescricao, fk_id_atendimento) VALUES 
('2024-02-01', 1), ('2024-02-01', 2), ('2024-02-02', 4), ('2024-02-03', 6),
('2024-02-04', 7), ('2024-02-05', 9), ('2024-02-05', 10), ('2024-02-06', 1),
('2024-02-06', 2), ('2024-02-07', 4);

-- EXAME
INSERT INTO exame (tipo, data_solicitacao, descricao_detalhada, fk_id_atendimento) VALUES 
('sangue', '2024-02-01', 'Hemograma completo', 1), ('urina', '2024-02-01', 'EAS', 2),
('imagem', '2024-02-02', 'Raio-X tórax', 4), ('fezes', '2024-02-03', 'Parasitológico', 6),
('sangue', '2024-02-04', 'Glicemia', 7), ('imagem', '2024-02-05', 'Ressonância', 9),
('sangue', '2024-02-05', 'Colesterol', 10), ('urina', '2024-02-06', 'Cultura', 1),
('imagem', '2024-02-06', 'Tomografia', 2), ('sangue', '2024-02-07', 'TGO/TGP', 4);

-- FATURA
INSERT INTO fatura (valor_fatura, status, forma_pagamento, data_emissao, data_vencimento, fk_id_plano, fk_id_atendimento) VALUES 
(150.00, 'pago', 'pix', '2024-02-01', '2024-02-15', 1, 1),
(500.00, 'pendente', 'cartao', '2024-02-01', '2024-02-20', 2, 2),
(200.00, 'em analise', 'dinheiro', '2024-02-02', '2024-02-25', 3, 4),
(1000.00, 'cancelado', 'pix', '2024-02-03', '2024-03-01', 4, 6),
(350.00, 'pago', 'cartao', '2024-02-04', '2024-03-05', 5, 7),
(1200.00, 'pendente', 'pix', '2024-02-05', '2024-03-10', 6, 9),
(450.00, 'pago', 'dinheiro', '2024-02-05', '2024-03-15', 7, 10),
(180.00, 'pago', 'pix', '2024-02-06', '2024-03-20', 8, 1),
(900.00, 'em analise', 'cartao', '2024-02-06', '2024-03-25', 9, 2),
(300.00, 'pendente', 'pix', '2024-02-07', '2024-03-30', 10, 4);

-- PRESCRICAO_MEDICAMENTO
INSERT INTO prescricao_medicamento (dosagem, quantidade, fk_id_prescricao, fk_id_medicamento) VALUES 
(500, 2, 1, 1), (750, 3, 2, 2), (1, 1, 3, 3), (20, 10, 4, 4), (50, 30, 5, 5),
(400, 1, 6, 6), (50, 1, 7, 7), (850, 2, 8, 8), (1, 1, 9, 9), (20, 30, 10, 10);

-- LAUDO
INSERT INTO laudo (resultado, data_resultado, fk_id_exame) VALUES 
('normal', '2024-02-02', 1), ('alterado', '2024-02-02', 2), ('normal', '2024-02-03', 3),
('critico', '2024-02-04', 4), ('normal', '2024-02-05', 5), ('alterado', '2024-02-06', 6),
('normal', '2024-02-06', 7), ('normal', '2024-02-07', 8), ('alterado', '2024-02-07', 9), ('normal', '2024-02-08', 10);

-- EXAME_LABORATORIO
INSERT INTO exame_laboratorio (custo, fk_id_laboratorio, fk_id_exame) VALUES 
(50.00, 1, 1), (30.00, 2, 2), (150.00, 1, 3), (40.00, 2, 4), (60.00, 1, 5),
(500.00, 2, 6), (70.00, 1, 7), (45.00, 2, 8), (300.00, 1, 9), (80.00, 2, 10);




























