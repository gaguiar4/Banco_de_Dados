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

create table plano_de_saude (
id_plano_de_saude serial primary key,
nome varchar(50),
cobertura cobertura_plano,
telefone_fixo char(11),
telefone_celular char(11)
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
	estado varchar(100) not null
);

create table paciente(
	id_paciente serial primary key,
	nome varchar(60),
	cpf char(11) unique,
	fk_endereco int default null,
	telefone_fixo char(11),
	telefone_celular char (11),
	data_nascimento date,
	fk_id_plano int,
	numero_casa int,
	foreign key(fk_endereco) references endereco(id_endereco)
	on delete cascade on update no action,
	foreign key(fk_id_plano) references plano_de_saude(id_plano_de_saude)
	on delete cascade on update no action
);

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
	telefone_fixo char(11),
	telefone_celular char(11)
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
('Hospital Santa Maria', '12345678000101'), ('Hospital Regional Oeste', '23456789000102'),
('Maternidade Vida', '34567890000103'), ('Hospital Infantil Feliz', '45678901000104'),
('Hospital do Coração', '56789012000105'), ('Clínica São José', '67890123000106'),
('Hospital Metropolitano', '78901234000107'), ('Hospital das Clínicas', '89012345000108'),
('Pronto Socorro Central', '90123456000109'), ('Hospital de Trauma', '01234567000110');

-- ENDERECO
INSERT INTO endereco (cep, rua, bairro, cidade, estado) VALUES 
(01001000, 'Praça da Sé', 'Sé', 'São Paulo', 'SP'), (20010000, 'Rua Primeiro de Março', 'Centro', 'Rio de Janeiro', 'RJ'),
(30110001, 'Avenida do Contorno', 'Centro', 'Belo Horizonte', 'MG'), (70040000, 'Esplanada dos Ministérios', 'Zona Cívico-Administrativa', 'Brasília', 'DF'),
(40010000, 'Rua da Bélgica', 'Comércio', 'Salvador', 'BA'), (60010000, 'Rua Castro e Silva', 'Centro', 'Fortaleza', 'CE'),
(80010000, 'Rua XV de Novembro', 'Centro', 'Curitiba', 'PR'), (90010000, 'Avenida Mauá', 'Centro', 'Porto Alegre', 'RS'),
(50010000, 'Avenida Cais do Apolo', 'Recife', 'Recife', 'PE'), (69005000, 'Rua Guilherme Moreira', 'Centro', 'Manaus', 'AM');

-- MEDICAMENTO
INSERT INTO medicamento (nome, laboratorio) VALUES 
('Dipirona', 'Medley'), ('Paracetamol', 'EMS'), ('Amoxicilina', 'Eurofarma'),
('Omeprazol', 'Aché'), ('Losartana', 'Neo Química'), ('Ibuprofeno', 'Bayer'),
('Sertralina', 'Libbs'), ('Metformina', 'Merck'), ('Salbutamol', 'GSK'), ('Atorvastatina', 'Pfizer');

-- LABORATORIO
INSERT INTO laboratorio (tipo) VALUES 
('interno'), ('externo'), ('interno'), ('externo'), ('interno'), 
('externo'), ('interno'), ('externo'), ('interno'), ('externo');

-- PESQUISA_SATISFACAO
INSERT INTO pesquisa_satisfacao (data_resposta, nota_geral, comentario, recomendaria, tempo_espera_avaliacao) VALUES 
('2024-01-10', 5, 'Excelente atendimento', true, 5), ('2024-01-11', 4, 'Bom, mas pode melhorar', true, 3),
('2024-01-12', 3, 'Regular', false, 2), ('2024-01-13', 5, 'Muito rápido', true, 5),
('2024-01-14', 1, 'Péssimo', false, 1), ('2024-01-15', 4, 'Médicos atenciosos', true, 4),
('2024-01-16', 5, 'Instalações limpas', true, 5), ('2024-01-17', 2, 'Demora excessiva', false, 1),
('2024-01-18', 4, 'Ok', true, 3), ('2024-01-19', 3, 'Médio', true, 2);

-- MEDICO
INSERT INTO medico (crm, nome, especialidade, telefone_fixo, telefone_celular) VALUES 
('123456SP', 'Dr. Arnaldo Silva', 'cardiologista', '1133445566', '11988776655'),
('223456RJ', 'Dra. Beatriz Souza', 'pediatria', '2133445566', '21988776655'),
('323456MG', 'Dr. Carlos Lima', 'clinico geral', '3133445566', '31988776655'),
('423456DF', 'Dra. Daniela Rosa', 'cardiologista', '6133445566', '61988776655'),
('523456PR', 'Dr. Eduardo Mota', 'pediatria', '4133445566', '41988776655'),
('623456RS', 'Dra. Fernanda Luz', 'clinico geral', '5133445566', '51988776655'),
('723456BA', 'Dr. Gabriel Costa', 'cardiologista', '7133445566', '71988776655'),
('823456CE', 'Dra. Helena Dias', 'pediatria', '8533445566', '85988776655'),
('923456PE', 'Dr. Igor Gomes', 'clinico geral', '8133445566', '81988776655'),
('023456AM', 'Dra. Julia Paes', 'cardiologista', '9233445566', '92988776655');

-- ENFERMEIRA (Incluindo hierarquia: enfermeira chefe)
INSERT INTO enfermeira (nome, cre, turno, id_enfermeira_chefe) VALUES 
('Ana Oliveira', '111222333', 'manha', NULL), ('Bruno Castro', '222333444', 'tarde', 1),
('Carla Neves', '333444555', 'noite', 1), ('Diego Rocha', '444555666', 'manha', NULL),
('Elaine Pires', '555666777', 'tarde', 4), ('Fabio Melo', '666777888', 'noite', 4),
('Gisele Reais', '777888999', 'manha', NULL), ('Hélio Santos', '888999000', 'tarde', 7),
('Iara Farias', '999000111', 'noite', 7), ('Joana Silva', '000111222', 'manha', NULL);

-- PLANO DE SAUDE
INSERT INTO plano_de_saude (nome, cobertura, telefone_fixo, telefone_celular) VALUES 
('Unimed', 'nacional', '1140040001', '11900000001'), ('Bradesco Saúde', 'nacional', '1140040002', '11900000002'),
('Amil', 'nacional', '1140040003', '11900000003'), ('SulAmérica', 'nacional', '1140040004', '11900000004'),
('Hapvida', 'regional', '8540040005', '85900000005'), ('Intermédica', 'regional', '1140040006', '11900000006'),
('Porto Seguro', 'nacional', '1140040007', '11900000007'), ('Cassi', 'nacional', '6140040008', '61900000008'),
('Golden Cross', 'regional', '2140040009', '21900000009'), ('Sompo Saúde', 'regional', '1140040010', '11900000010');

-- ALA
INSERT INTO ala (tipo, leitos_disponiveis, fk_id_hospital, fk_id_enfermeira) VALUES 
('uti', 5, 1, 1), ('enfermaria', 10, 1, 2), ('pediatria', 8, 2, 3),
('uti', 3, 3, 4), ('enfermaria', 12, 4, 5), ('pediatria', 6, 5, 6),
('uti', 4, 6, 7), ('enfermaria', 15, 7, 8), ('pediatria', 10, 8, 9), ('uti', 2, 9, 10);

-- CREDENCIAMENTO
INSERT INTO credenciamento (data, fk_id_hospital, fk_id_plano_de_saude) VALUES 
('2023-01-01', 1, 1), ('2023-01-01', 1, 2), ('2023-02-15', 2, 3), ('2023-03-20', 3, 4),
('2023-04-10', 4, 5), ('2023-05-05', 5, 6), ('2023-06-12', 6, 7), ('2023-07-30', 7, 8),
('2023-08-14', 8, 9), ('2023-09-22', 9, 10);

-- PACIENTE
INSERT INTO paciente (nome, cpf, fk_endereco, telefone_fixo, telefone_celular, data_nascimento, fk_id_plano, numero_casa) VALUES 
('João Silva', '11122233344', 1, '1133221100', '11999990001', '1985-05-20', 1, 101),
('Maria Souza', '22233344455', 2, '2133221100', '21999990002', '1990-08-15', 2, 202),
('Pedro Alvares', '33344455566', 3, '3133221100', '31999990003', '1975-12-01', 3, 303),
('Ana Paula', '44455566677', 4, '6133221100', '61999990004', '2000-02-10', 4, 404),
('Carlos Magno', '55566677788', 5, '7133221100', '71999990005', '1960-11-25', 5, 505),
('Fernanda Lima', '66677788899', 6, '8533221100', '85999990006', '1995-04-30', 6, 606),
('Roberto Carlos', '77788899900', 7, '4133221100', '41999990007', '1950-01-01', 7, 707),
('Juliana Paes', '88899900011', 8, '5133221100', '51999990008', '1982-07-12', 8, 808),
('Marcos Mion', '99900011122', 9, '8133221100', '81999990009', '1978-03-22', 9, 909),
('Sandy Leah', '00011122233', 10, '9233221100', '92999990010', '1983-09-18', 10, 1010);

-- LEITO
INSERT INTO leito (status, fk_id_ala) VALUES 
('livre', 1), ('ocupado', 1), ('em manutencao', 2), ('livre', 2), ('ocupado', 3),
('livre', 4), ('ocupado', 5), ('em manutencao', 6), ('livre', 7), ('ocupado', 8);

-- ATENDIMENTO
INSERT INTO atendimento (data_atendimento, tipo, observacoes, status, fk_id_medico, fk_id_paciente, fk_id_pesquisa) VALUES 
('2024-02-01 10:00:00', 'consulta', 'Dor de cabeça constante', 'realizado', 1, 1, 1),
('2024-02-01 11:30:00', 'emergencia', 'Fratura exposta', 'realizado', 2, 2, 2),
('2024-02-02 09:00:00', 'revisao', 'Retorno pós-cirúrgico', 'agendado', 3, 3, 3),
('2024-02-02 14:00:00', 'consulta', 'Check-up anual', 'realizado', 4, 4, 4),
('2024-02-03 08:00:00', 'emergencia', 'Crise asmática', 'cancelado', 5, 5, 5),
('2024-02-03 16:00:00', 'consulta', 'Dores lombares', 'realizado', 6, 6, 6),
('2024-02-04 10:00:00', 'revisao', 'Avaliação de exames', 'realizado', 7, 7, 7),
('2024-02-04 15:30:00', 'consulta', 'Gripe forte', 'agendado', 8, 8, 8),
('2024-02-05 13:00:00', 'emergencia', 'Acidente doméstico', 'realizado', 9, 9, 9),
('2024-02-05 17:00:00', 'consulta', 'Alergia cutânea', 'realizado', 10, 10, 10);

-- INTERNACAO
INSERT INTO internacao (data_entrada, data_saida, status, fk_id_paciente, fk_id_leito) VALUES 
('2024-01-01', '2024-01-05', false, 1, 1), ('2024-01-10', '2024-01-15', false, 2, 2),
('2024-02-01', '2024-02-10', true, 3, 5), ('2024-02-05', '2024-02-12', true, 4, 7),
('2024-02-10', NULL, true, 5, 10), ('2024-02-15', NULL, true, 6, 2),
('2024-02-20', '2024-02-25', false, 7, 3), ('2024-03-01', '2024-03-05', false, 8, 8),
('2024-03-10', NULL, true, 9, 5), ('2024-03-15', NULL, true, 10, 10);

-- PRESCRICAO
INSERT INTO prescricao (data_prescricao, fk_id_atendimento) VALUES 
('2024-02-01', 1), ('2024-02-01', 2), ('2024-02-02', 4), ('2024-02-03', 6),
('2024-02-04', 7), ('2024-02-05', 9), ('2024-02-05', 10), ('2024-02-06', 1),
('2024-02-06', 2), ('2024-02-07', 4);

-- EXAME
INSERT INTO exame (tipo, data_solicitacao, descricao_detalhada, fk_id_atendimento) VALUES 
('sangue', '2024-02-01', 'Hemograma completo', 1), ('urina', '2024-02-01', 'EAS', 2),
('imagem', '2024-02-02', 'Raio-X de Tórax', 4), ('fezes', '2024-02-03', 'Parasitológico', 6),
('sangue', '2024-02-04', 'Glicemia de jejum', 7), ('imagem', '2024-02-05', 'Ressonância Magnética', 9),
('sangue', '2024-02-05', 'Colesterol Total', 10), ('urina', '2024-02-06', 'Urocultura', 1),
('imagem', '2024-02-06', 'Tomografia Computadorizada', 2), ('sangue', '2024-02-07', 'TGO e TGP', 4);

-- FATURA
INSERT INTO fatura (valor_fatura, status, forma_pagamento, data_emissao, data_vencimento, fk_id_plano, fk_id_atendimento) VALUES 
(150.00, 'pago', 'pix', '2024-02-01', '2024-02-10', 1, 1),
(5000.00, 'pendente', 'cartao', '2024-02-01', '2024-02-15', 2, 2),
(200.00, 'em analise', 'dinheiro', '2024-02-02', '2024-02-20', 3, 4),
(120.00, 'pago', 'pix', '2024-02-03', '2024-02-13', 4, 6),
(80.00, 'pago', 'cartao', '2024-02-04', '2024-02-14', 5, 7),
(1200.00, 'pendente', 'pix', '2024-02-05', '2024-02-25', 6, 9),
(300.00, 'pago', 'dinheiro', '2024-02-05', '2024-02-15', 7, 10),
(150.00, 'cancelado', 'cartao', '2024-02-06', '2024-02-16', 8, 1),
(450.00, 'pago', 'pix', '2024-02-06', '2024-02-26', 9, 2),
(210.00, 'em analise', 'dinheiro', '2024-02-07', '2024-02-17', 10, 4);

-- PRESCRICAO_MEDICAMENTO
INSERT INTO prescricao_medicamento (dosagem, quantidade, fk_id_prescricao, fk_id_medicamento) VALUES 
(500.0, 2, 1, 1), (750.0, 3, 2, 2), (1.0, 1, 3, 3), (20.0, 10, 4, 4), (50.0, 30, 5, 5),
(400.0, 1, 6, 6), (50.0, 1, 7, 7), (850.0, 2, 8, 8), (2.0, 1, 9, 9), (10.0, 30, 10, 10);

-- LAUDO
INSERT INTO laudo (resultado, data_resultado, fk_id_exame) VALUES 
('normal', '2024-02-02', 1), ('alterado', '2024-02-02', 2), ('normal', '2024-02-03', 3),
('critico', '2024-02-04', 4), ('normal', '2024-02-05', 5), ('alterado', '2024-02-06', 6),
('normal', '2024-02-06', 7), ('normal', '2024-02-07', 8), ('alterado', '2024-02-07', 9), ('normal', '2024-02-08', 10);

-- EXAME_LABORATORIO
INSERT INTO exame_laboratorio (custo, fk_id_laboratorio, fk_id_exame) VALUES 
(50.00, 1, 1), (30.00, 2, 2), (150.00, 1, 3), (40.00, 2, 4), (60.00, 1, 5),
(500.00, 2, 6), (70.00, 1, 7), (45.00, 2, 8), (300.00, 1, 9), (80.00, 2, 10);

---------------------------------------------CONSULTAS DQL-----------------------------------------------------------------------
















