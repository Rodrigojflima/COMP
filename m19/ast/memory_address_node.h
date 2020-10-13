#ifndef __M19_MEMORY_ADDRESSNODE_H__
#define __M19_MEMORY_ADDRESSNODE_H__

#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include <cdk/ast/unary_expression_node.h>

namespace m19 {

	/**
	* Class for describing memory address node 
	**/

	class memory_address_node: public cdk::expression_node{
		cdk::lvalue_node *_lvalue;

	public:
		inline memory_address_node(int lineno, cdk::lvalue_node *arg) :
			cdk::expression_node(lineno), _lvalue(arg){}

	public:
		inline cdk::lvalue_node *lvalue() {
			return _lvalue;
		}

	public:
		void accept(basic_ast_visitor *sp, int level) {
			sp->do_memory_address_node(this, level);
		}

	};

} // m19

#endif
