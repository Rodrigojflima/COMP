#ifndef __M19_NEXTNODE_H__
#define __M19_NEXTNODE_H__

#include <cdk/ast/basic_node.h>

namespace m19 {

	/**
	* Class for describing next node
	**/

	class next_node: public cdk::basic_node {

	public:
		inline next_node(int lineno) :
			cdk::basic_node(lineno){
		}

	public:
		void accept(basic_ast_visitor *sp, int level) {
			sp->do_next_node(this, level);
		}

	};

} // m19

#endif