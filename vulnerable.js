// ARQUIVO PROPOSITALMENTE VULNERÁVEL (CP05). Não usar em produção.
function calcular(entradaDoUsuario) {
  return eval(entradaDoUsuario);
}
module.exports = { calcular };
