#ifndef __M19_STOPNODE_H__
#define __M19_STOPNODE_H__

#include <cdk/ast/basic_node.h>

namespace m19 {

	/**
	* Class for describing stop node
	**/

	class stop_node: public cdk::basic_node {

	public:
		inline stop_node(int lineno) :
			cdk::basic_node(lineno){
		}

	public:
		void accept(basic_ast_visitor *sp, int level) {
			sp->do_stop_node(this, level);
		}

	};

} // m19

#endif