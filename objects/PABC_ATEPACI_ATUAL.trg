create or replace trigger PABC_ATEPACI_ATUAL
after insert or update on pabc_atepaci
for each row
declare

atendimento_paciente_w	atendimento_paciente%rowtype;
pessoa_classif_w		pessoa_classif%rowtype;

begin

if	(:new.ie_vip = 'S') and (inserting or :old.ie_vip = 'N') then
	begin
	select	*
	into	atendimento_paciente_w
	from	atendimento_paciente
	where	nr_atendimento = :new.nr_atendimento;

	begin
	select	*
	into	pessoa_classif_w
	from	pessoa_classif
	where	cd_pessoa_fisica = atendimento_paciente_w.cd_pessoa_fisica
	and	nr_seq_classif = 2
	and	rownum = 1;
	
	update	pessoa_classif
	set	dt_atualizacao = atendimento_paciente_w.dt_atualizacao,
		nm_usuario = atendimento_paciente_w.nm_usuario
	where	nr_sequencia = pessoa_classif_w.nr_sequencia;
	exception
	when others then
		begin
		select	pessoa_classif_seq.nextval
		into	pessoa_classif_w.nr_sequencia
		from	dual;
		
		pessoa_classif_w.nm_usuario 		:=	atendimento_paciente_w.nm_usuario;
		pessoa_classif_w.dt_atualizacao 	:=	atendimento_paciente_w.dt_atualizacao;
		pessoa_classif_w.cd_pessoa_fisica 	:=	atendimento_paciente_w.cd_pessoa_fisica;
		pessoa_classif_w.nr_seq_classif 	:=	2;
		pessoa_classif_w.dt_inicio_vigencia 	:=	sysdate;
		
		insert into pessoa_classif values pessoa_classif_w;
		end;
	end;
	exception
	when others then
		null;
	end;
end if;

end PABC_ATEPACI_ATUAL;
/