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
	on update no action on delete set null  
);

create table ala (
id_ala serial primary key,
tipo tipo_ala,
leitos_disponiveis int,
fk_id_hospital int,
fk_id_enfermeira int,
foreign key(fk_id_hospital) references hospital(id_hospital)
	on update no action on delete cascade, 
foreign key(fk_id_enfermeira) references enfermeira(id_enfermeira)
	on update no action on delete set null
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
	on update no action on delete cascade,
foreign key(fk_id_plano_de_saude) references plano_de_saude(id_plano_de_saude)
	 on update no action on delete cascade
);

create table endereco(
	id_endereco serial primary key,
	cep char(8) unique not null,
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
		on update no action on delete cascade,
	foreign key(fk_id_plano) references plano_de_saude(id_plano_de_saude)
		on update no action on delete cascade
);


create table internacao(
		id_internacao serial primary key,
		data_entrada date,
		data_saida date check(data_saida > data_entrada),
		status boolean,
		fk_id_paciente int,
		fk_id_leito int,
		foreign key(fk_id_paciente) references paciente(id_paciente)
			on update no action
			on delete set null,
		foreign key(fk_id_leito) references leito(id_leito)
			on update no action
			on delete set null
);

--Index unico parcial guarda o id leito temporariamente enquanto ele estiver ocupado
create unique index idx_leito_unico_ocupado
on internacao (fk_id_leito)
where (status = true);

create table medico(
	id_medico serial primary key,
	crm char(8) unique not null,
	nome varchar(60) not null,
	especialidade tipo_especialidade not null,
	telefone_fixo char(11),
	telefone_celular char(11)
);

create table atendimento(
	id_atendimento serial primary key,
	data_atendimento timestamp,
	tipo tipo_atendimento,
	observacoes text,
	status status_atendimento,
	fk_id_medico int,
	fk_id_paciente int,
	foreign key(fk_id_medico) references medico(id_medico)
		on update no action
		on delete cascade,
	foreign key(fk_id_paciente) references paciente(id_paciente)
		on update no action
		on delete cascade
);

create table pesquisa_satisfacao(
	id_pesquisa serial primary key,
	fk_id_atendimento int,
	data_resposta date,
	nota_geral int check(nota_geral between 1 and 5),
	comentario text,
	recomendaria boolean,
	tempo_espera_avaliacao int check(tempo_espera_avaliacao between 1 and 5),
	foreign key(fk_id_atendimento) references atendimento(id_atendimento)
		on update no action
		on delete cascade
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
		on update no action
		on delete cascade,
	foreign key(fk_id_medicamento) references medicamento(id_medicamento)
		on update no action
		on delete cascade
);

create table exame( 
	id_exame serial primary key,
	tipo tipo_exame,
	data_solicitacao date,
	descricao_detalhada text,
	fk_id_atendimento int,
	foreign key(fk_id_atendimento) references atendimento(id_atendimento)
		on update no action
		on delete cascade
);

create table laudo( 
	id_laudo serial primary key,
	resultado resultado_exame, 
	data_resultado date,
	nome_arquivo varchar(100),
	arquivo_laudo bytea,
	fk_id_exame int,
	foreign key(fk_id_exame) references exame(id_exame)
		on update no action 
		on delete cascade
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
		on update no action
		on delete cascade,
	foreign key(fk_id_exame) references exame(id_exame) 
		on update no action
		on delete cascade
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
		on update no action
		on delete cascade,
	foreign key (fk_id_atendimento) references atendimento(id_atendimento)
		on update no action
		on delete cascade
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
('01001000', 'Praça da Sé', 'Sé', 'São Paulo', 'SP'), ('20010000', 'Rua Primeiro de Março', 'Centro', 'Rio de Janeiro', 'RJ'),
('30110001', 'Avenida do Contorno', 'Centro', 'Belo Horizonte', 'MG'), ('70040000', 'Esplanada dos Ministérios', 'Zona Cívico-Administrativa', 'Brasília', 'DF'),
('40010000', 'Rua da Bélgica', 'Comércio', 'Salvador', 'BA'), ('60010000', 'Rua Castro e Silva', 'Centro', 'Fortaleza', 'CE'),
('80010000', 'Rua XV de Novembro', 'Centro', 'Curitiba', 'PR'), ('90010000', 'Avenida Mauá', 'Centro', 'Porto Alegre', 'RS'),
('50010000', 'Avenida Cais do Apolo', 'Recife', 'Recife', 'PE'), ('69005000', 'Rua Guilherme Moreira', 'Centro', 'Manaus', 'AM');

-- MEDICAMENTO
INSERT INTO medicamento (nome, laboratorio) VALUES 
('Dipirona', 'Medley'), ('Paracetamol', 'EMS'), ('Amoxicilina', 'Eurofarma'),
('Omeprazol', 'Aché'), ('Losartana', 'Neo Química'), ('Ibuprofeno', 'Bayer'),
('Sertralina', 'Libbs'), ('Metformina', 'Merck'), ('Salbutamol', 'GSK'), ('Atorvastatina', 'Pfizer');

-- LABORATORIO
INSERT INTO laboratorio (tipo) VALUES 
('interno'), ('externo');

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
('uti', 5, 1, 1), ('enfermaria', 10, 1, 2), ('pediatria', 8, 2, 3);

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
('livre', 3), ('ocupado', 1), ('em manutencao', 2), ('livre', 2), ('ocupado', 3);

-- ATENDIMENTO
INSERT INTO atendimento (data_atendimento, tipo, observacoes, status, fk_id_medico, fk_id_paciente) VALUES 
('2024-02-01 10:00:00', 'consulta', 'Dor de cabeça constante', 'realizado', 1, 1),
('2024-02-01 11:30:00', 'emergencia', 'Fratura exposta', 'realizado', 2, 2),
('2024-02-02 09:00:00', 'revisao', 'Retorno pós-cirúrgico', 'agendado', 3, 3),
('2024-02-02 14:00:00', 'consulta', 'Check-up anual', 'realizado', 4, 4),
('2024-02-03 08:00:00', 'emergencia', 'Crise asmática', 'cancelado', 5, 5),
('2024-02-03 16:00:00', 'consulta', 'Dores lombares', 'realizado', 6, 6),
('2024-02-04 10:00:00', 'revisao', 'Avaliação de exames', 'realizado', 7, 7),
('2024-02-04 15:30:00', 'consulta', 'Gripe forte', 'agendado', 8, 8),
('2024-02-05 13:00:00', 'emergencia', 'Acidente doméstico', 'realizado', 9, 9),
('2024-02-05 17:00:00', 'consulta', 'Alergia cutânea', 'realizado', 10, 10);

-- PESQUISA_SATISFACAO
INSERT INTO pesquisa_satisfacao (data_resposta, fk_id_atendimento, nota_geral, comentario, recomendaria, tempo_espera_avaliacao) VALUES 
('2024-01-10',1, 5, 'Excelente atendimento', true, 5), ('2024-01-11',2, 4, 'Bom, mas pode melhorar', true, 3),
('2024-01-12',3, 3, 'Regular', false, 2), ('2024-01-13',4, 5, 'Muito rápido', true, 5),
('2024-01-14',5, 1, 'Péssimo', false, 1), ('2024-01-15',6, 4, 'Médicos atenciosos', true, 4),
('2024-01-16',7, 5, 'Instalações limpas', true, 5), ('2024-01-17',8, 2, 'Demora excessiva', false, 1),
('2024-01-18',9, 4, 'Ok', true, 3), ('2024-01-19',10, 3, 'Médio', true, 2);

-- INTERNACAO
INSERT INTO internacao (data_entrada, data_saida, status, fk_id_paciente, fk_id_leito) VALUES 
('2024-01-01', '2024-01-05', false, 1, 1), ('2024-01-10', '2024-01-15', false, 2, 2),
('2024-02-01', '2024-02-10', true, 3, 5), ('2024-02-05', '2024-02-12', true, 4, 7),
('2024-02-10', NULL, true, 5, 10), ('2024-02-15', NULL, true, 6, 2),
('2024-02-20', '2024-02-25', false, 7, 3), ('2024-03-01', '2024-03-05', false, 8, 8),
('2024-03-10', NULL, true, 9, 9), ('2024-03-15', NULL, true, 10, 4);

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
INSERT INTO laudo (resultado, data_resultado, nome_arquivo, arquivo_laudo, fk_id_exame) VALUES 
('normal',   '2024-02-02', 'laudo_01.pdf', '\x255044462d312e350a25d0d4c5d80a312030206f626a0a3c3c2f54797065
2f436174616c6f672f50616765732032203020520a3e3e0a656e646f626a0a
322030206f626a0a3c3c2f547970652f50616765732f436f756e7420332f4b
696473205b33203020522034203020522035203020525d0a3e3e0a656e646f
626a0a', 1),
('alterado', '2024-02-02', 'laudo_02.jpg', '\xffd8ffe000104a46494600010101006000600000ffe10c58457869660000
49492a00080000000a00000001000000010000000100000000000000ffe20c
4c4943435f50524f46494c4500010100000c3c6c636d7302100000', 2),
('normal',   '2024-02-03', 'laudo_03.pdf', '\x255044462d312e350a25d0d4c5d80a312030206f626a0a3c3c2f54797065
2f436174616c6f672f50616765732032203020520a3e3e0a656e646f626a0a
322030206f626a0a3c3c2f547970652f50616765732f436f756e7420332f4b
696473205b33203020522034203020522035203020525d0a3e3e0a656e646f
626a0a', 3),
('critico',  '2024-02-04', 'laudo_04.pdf', '\x255044462d312e350a25d0d4c5d80a312030206f626a0a3c3c2f54797065
2f436174616c6f672f50616765732032203020520a3e3e0a656e646f626a0a
322030206f626a0a3c3c2f547970652f50616765732f436f756e7420332f4b
696473205b33203020522034203020522035203020525d0a3e3e0a656e646f
626a0a', 4),
('normal',   '2024-02-05', 'laudo_05.jpg', '\xffd8ffe000104a46494600010101006000600000ffe10c58457869660000
49492a00080000000a00000001000000010000000100000000000000ffe20c
4c4943435f50524f46494c4500010100000c3c6c636d7302100000', 5),
('alterado', '2024-02-06', 'laudo_06.jpg', '\xffd8ffe000104a46494600010101006000600000ffe10c58457869660000
49492a00080000000a00000001000000010000000100000000000000ffe20c
4c4943435f50524f46494c4500010100000c3c6c636d7302100000', 6),
('normal',   '2024-02-06', 'laudo_07.pdf', '\x255044462d312e350a25d0d4c5d80a312030206f626a0a3c3c2f54797065
2f436174616c6f672f50616765732032203020520a3e3e0a656e646f626a0a
322030206f626a0a3c3c2f547970652f50616765732f436f756e7420332f4b
696473205b33203020522034203020522035203020525d0a3e3e0a656e646f
626a0a', 7),
('normal',   '2024-02-07', 'laudo_08.jpg', '\xffd8ffe000104a46494600010101006000600000ffe10c58457869660000
49492a00080000000a00000001000000010000000100000000000000ffe20c
4c4943435f50524f46494c4500010100000c3c6c636d7302100000', 8),
('alterado', '2024-02-07', 'laudo_09.jpg', '\xffd8ffe000104a46494600010101006000600000ffe10c58457869660000
49492a00080000000a00000001000000010000000100000000000000ffe20c
4c4943435f50524f46494c4500010100000c3c6c636d7302100000', 9),
('normal',   '2024-02-08', 'laudo_10.pdf', '\x255044462d312e350a25d0d4c5d80a312030206f626a0a3c3c2f54797065
2f436174616c6f672f50616765732032203020520a3e3e0a656e646f626a0a
322030206f626a0a3c3c2f547970652f50616765732f436f756e7420332f4b
696473205b33203020522034203020522035203020525d0a3e3e0a656e646f
626a0a', 10);


-- EXAME_LABORATORIO
INSERT INTO exame_laboratorio (custo, fk_id_laboratorio, fk_id_exame) VALUES 
(50.00, 1, 1), (30.00, 2, 2), (150.00, 1, 3), (40.00, 2, 4), (60.00, 1, 5),
(500.00, 2, 6), (70.00, 1, 7), (45.00, 2, 8), (300.00, 1, 9), (80.00, 2, 10);

--DADOS PARA A QUESTÃO 03
INSERT INTO atendimento (data_atendimento, tipo, observacoes, status, fk_id_medico, fk_id_paciente) VALUES 
('2026-03-01 08:00:00', 'consulta', 'Rotina Março', 'realizado', 1, 9),
('2026-03-05 09:30:00', 'emergencia', 'Sintomas gripais', 'realizado', 2, 8),
('2026-03-10 10:00:00', 'consulta', 'Avaliação trimestral', 'realizado', 1, 7),
('2026-03-12 14:00:00', 'consulta', 'Dor articular', 'realizado', 3, 4),
('2026-03-15 11:00:00', 'revisao', 'Retorno de rotina', 'realizado', 1, 5),
('2026-03-18 15:00:00', 'consulta', 'Check-up', 'realizado', 5, 6),
('2026-03-20 08:30:00', 'emergencia', 'Crise alérgica', 'realizado', 7, 3),
('2026-03-22 10:45:00', 'consulta', 'Acompanhamento', 'realizado', 8, 2),
('2026-03-24 13:00:00', 'revisao', 'Pós-exame', 'realizado', 9, 1),
('2026-03-25 16:20:00', 'consulta', 'Queixa de cansaço', 'realizado', 10, 10);

INSERT INTO exame (tipo, data_solicitacao, descricao_detalhada, fk_id_atendimento) VALUES 
('sangue', '2026-02-02', 'Hemograma solicitado para rotina', 11),
('urina', '2026-02-06', 'Sumário de urina - suspeita de infecção', 12),
('imagem', '2026-02-11', 'Ultrassom abdominal total', 13),
('sangue', '2026-02-13', 'Dosagem de Vitamina D e Cálcio', 14),
('fezes', '2026-02-16', 'Pesquisa de sangue oculto', 15),
('imagem', '2026-03-19', 'Raio-X de coluna lombo-sacra', 16),
('sangue', '2026-03-21', 'IgE específico para alérgenos', 17),
('urina', '2026-03-23', 'Urocultura com antibiograma', 18),
('imagem', '2026-03-24', 'Ecocardiograma transtorácico', 19),
('sangue', '2026-03-26', 'Perfil lipídico e glicemia', 20);

-- Inserindo laudos com resultado NULL para os exames de Março/2026
INSERT INTO laudo (resultado, data_resultado, fk_id_exame) VALUES 
('normal', NULL, 11),
('normal', NULL, 12),
('alterado', NULL, 13),
('normal', NULL, 14),
('critico', NULL, 15),
('normal', NULL, 16),
('alterado', NULL, 17),
('normal', NULL, 18),
('critico', NULL, 19),
('normal', NULL, 20);


INSERT INTO fatura (valor_fatura, status, forma_pagamento, data_emissao, data_vencimento, fk_id_plano, fk_id_atendimento) VALUES 
(150.00, 'pago', 'pix', '2026-02-01', '2026-02-10', 1, 1),
(1250.00, 'pago', 'cartao', '2026-02-01', '2026-02-15', 2, 2),
(200.00, 'em analise', 'pix', '2026-02-02', '2026-02-20', 3, 4),
(150.00, 'pago', 'cartao', '2026-02-03', '2026-02-13', 4, 6),
(100.00, 'pago', 'cartao', '2026-02-04', '2026-02-14', 5, 1);

INSERT INTO fatura (valor_fatura, status, forma_pagamento, data_emissao, data_vencimento, fk_id_plano, fk_id_atendimento) VALUES 
(150.00, 'pago', 'dinheiro', '2026-02-01', '2026-02-10', 1, 1),
(1250.00, 'pago', 'cartao', '2026-02-01', '2026-02-15', 2, 2),
(200.00, 'em analise', 'pix', '2026-02-02', '2026-02-20', 3, 4),
(350.00, 'pago', 'cartao', '2026-02-03', '2026-02-13', 4, 6),
(200.00, 'pago', 'cartao', '2026-02-04', '2026-02-14', 1, 1);

---------------------------------------------CONSULTAS DQL-----------------------------------------------------------------------

-- 1# Médicos e Especialidades
select m.nome as medico, m.especialidade, m.telefone_fixo, m.telefone_celular 
from medico m
where m.especialidade = 'cardiologista';

-- 2# Pacientes e Planos de Saúde
select p.nome, p.cpf, pds.nome as plano
from paciente p
inner join plano_de_saude pds 
on p.fk_id_plano  = pds.id_plano_de_saude 
where pds.nome = 'Unimed';

-- 3# Exames Pendentes
select e.id_exame, e.tipo, e.data_solicitacao, e.descricao_detalhada, l.data_resultado 
from exame e
inner join laudo l
on e.id_exame = l.fk_id_exame 
where l.data_resultado isnull and e.data_solicitacao between '2026-03-01' and '2026-03-31';

-- 4# Quantidade de exames por laboratório
select l.tipo as tipo_laboratorio, count(el.fk_id_laboratorio) as qtd_exames
from exame_laboratorio el
inner join laboratorio l
on el.fk_id_laboratorio = l.id_laboratorio
group by l.tipo;

-- 5# Internações ativas
select p.nome as paciente, l.id_leito as numero_leito, i.data_entrada as data_internacao
from paciente p
inner join internacao i
on p.id_paciente  = i.fk_id_paciente 
inner join leito l
on i.fk_id_leito  = l.id_leito
where i.data_saida is null;

-- 6# Atendimentos por médico
select m.nome as medico, count(a.fk_id_medico) as atendimento
from medico m
inner join atendimento a
on m.id_medico  = a.fk_id_medico 
where a.data_atendimento between '2026-03-01' and '2026-03-31'
group by m.nome;

-- 7# Médico com maior número de atendimentos
select m.nome as medico, count(a.fk_id_medico) as atendimento
from medico m
inner join atendimento a
on m.id_medico  = a.fk_id_medico 
where a.data_atendimento between '2026-03-01' and '2026-03-31'
group by m.nome 
order by atendimento desc
limit 1;

-- 8# Ocupação de Leitos por Ala

select ala.tipo as ala, ala.leitos_disponiveis, count(leito.fk_id_ala) as leitos_ocupados, round((count(leito.fk_id_ala) ::numeric/ ala.leitos_disponiveis*100), 2) as percentual_ocupacao
from leito
join ala
on leito.fk_id_ala  = ala.id_ala
where leito.status = 'ocupado'
group by ala.tipo, ala.leitos_disponiveis;

-- 9# Faturamento por Plano de Saúde

select pl.nome, sum (f.valor_fatura) as total
from plano_de_saude pl
inner join fatura f
on f.fk_id_plano = pl.id_plano_de_saude 
where f.status = 'pago' and f.data_emissao between '2026-01-01' and '2026-12-31'
group by pl.nome;

-- 10# Prescrições de Medicamentos

select m.nome, count(pm.fk_id_medicamento) as Quantidade_Prescricoes from prescricao_medicamento pm 
inner join medicamento m
 on m.id_medicamento = pm.fk_id_medicamento
    group by(m.nome)
        order by Quantidade_Prescricoes desc
limit 2;

-- 11# Médicos e pacientes por especialidade

select m.nome as medico, m.especialidade,
    count (a.fk_id_paciente) as quantidades_pacientes
from medico m
inner join atendimento a
    on a.fk_id_medico  = m.id_medico
group by m.nome, m.especialidade;

-- 12# Leitos com Internações Prolongadas --

select l.id_leito as numero_leito, p.nome, i.data_entrada from internacao i
inner join paciente p
    on i.fk_id_paciente  = p.id_paciente
 inner join leito l
   on i.fk_id_leito = l.id_leito
where current_date - i.data_entrada > 15 and i.status = true;

-- 13# faturamento por Tipo de Atendimento
select a.tipo, sum(f.valor_fatura) as Valor_Total_Faturado from fatura f
inner join atendimento a
    on f.fk_id_atendimento = a.id_atendimento
where f.status = 'pago'
group by(a.tipo);

-- 14# faturamento plano de saude

select pl.nome , sum (f.valor_fatura) as total_faturado
from fatura f
inner join plano_de_saude pl 
    on f.fk_id_plano = pl.id_plano_de_saude 
where pl.nome = 'Hapvida'
and f.status = 'pago'
group by pl.nome;


-- Comando SQL para update -- 

update enfermeira
set nome = 'Roberta'
where id_enfermeira = 1;

-- Comando SQL para remoção --

delete from laudo
where id_laudo = 1;