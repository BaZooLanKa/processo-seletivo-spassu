<?php

declare(strict_types=1);

use Phinx\Migration\AbstractMigration;

final class DesafioInsertUpdateRecursoAcaoProcesso extends AbstractMigration
{
	public function up(): void
	{
		// 1. Definição dos dados da carga
		$idRecurso    	= 532;
		$nome         	= 'Vincular boleto';
		$ativo        	= 1;
		$loginUsuario 	= 'Marcelo';
		$atualizaDados	= filter_var(
					getenv('ATUALIZA') ?: false,
					FILTER_VALIDATE_BOOLEAN
				);

		$queryUsuario = $this->getQueryBuilder('select');

		// 2. Busca Dinâmica do Usuário via Query Builder Nativo
		$usuario = $queryUsuario
			->select(['id_usuario'])
			->from('usuario')
			->where(['nome_usuario' => $loginUsuario])
			->execute()
			->fetch('assoc');

		if (!$usuario) {
			throw new \RuntimeException("Erro: Usuário '{$loginUsuario}' não cadastrado.");
		}

		$idUsuarioInclusao = $usuario['id_usuario'];

		$queryRecurso = $this->getQueryBuilder('select');

	        // 3. Verificação de Existência do Recurso via Query Builder Nativo
	        $recurso = $queryRecurso
			->select(['qtde' => 'COUNT(*)'])
			->from('recurso_acao_processo')
			->where(['id_recurso_acao_processo' => $idRecurso])
			->execute()
			->fetch('assoc');

	        // Instancia a tabela para operações de escrita
	        $tabela = $this->table('recurso_acao_processo');

		// Cenário A: O registro não existe (Inserção Inédita).
		if ((int)$recurso['qtde'] === 0) {

			$dadosInsert = [
				'id_recurso_acao_processo' => $idRecurso,
				'nome'                     => $nome,
				'ativo'                    => $ativo,
				'data_inclusao'            => date('Y-m-d H:i:s'),
				'id_usuario_inclusao'      => $idUsuarioInclusao
			];

			$tabela->insert($dadosInsert)->saveData();

		} else {

			// Cenário B: O registro já existe, e é pra atualizar os dados.
			if ($atualizaDados) {
				$dadosUpdate = [
					'nome'                => $nome,
					'ativo'               => $ativo,
					//'data_inclusao'       => date('Y-m-d H:i:s'),
					'id_usuario_inclusao' => $idUsuarioInclusao
				];

				$this->getQueryBuilder()
					->update('recurso_acao_processo')
					->set($dadosUpdate)
					->where(['id_recurso_acao_processo' => $idRecurso])
					->execute();

			} else {

				// Cenário C: O registro existe, e é pra ignorá-lo.
			}

	        }

	}

	public function down(): void
	{
		$idRecursoParaDeletar = 532;

		$this->getQueryBuilder()
			->delete('recurso_acao_processo')
			->where(['id_recurso_acao_processo' => $idRecursoParaDeletar])
			->execute();
	}
}
