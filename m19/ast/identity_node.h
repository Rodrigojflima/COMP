#ifndef __M19_IDENTITYNODE_H__
#define __M19_IDENTITYNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/unary_expression_node.h>

namespace m19 {

	/**
	* Class for describing the identity nodes
	**/

	class identity_node: public cdk::unary_expression_node {

	public:
		inline identity_node(int lineno, cdk::expression_node *arg) :
			cdk::unary_expression_node(lineno, arg) {}

	public:
		void accept(basic_ast_visitor *sp, int level) {
			sp->do_identity_node(this, level);
		}
		
	};

} // m19

#endif