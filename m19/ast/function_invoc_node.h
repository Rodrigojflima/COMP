#ifndef __M19_FUNCTIONINVOCNODE_H__
#define __M19_FUNCTIONINVOCNODE_H__

#include <string>
#include <cdk/ast/expression_node.h>
#include <cdk/ast/sequence_node.h>

namespace m19 {

  /**
   * Class for describing function_invoc nodes.
   */

	class function_invoc_node: public cdk::expression_node {
		std::string _id;
		cdk::sequence_node *_args;

	public:
		inline function_invoc_node(int lineno, std::string *id, cdk::sequence_node *args):
        cdk::expression_node(lineno), _id(*id), _args(args) {
		}

	public:
		inline const std::string id() const {
      		return _id;
		}
    	inline cdk::sequence_node *args() {
			return _args;
		}

	public:
		void accept(basic_ast_visitor *sp, int level) {
      		sp->do_function_invoc_node(this, level);
		}

	};

} // m19

#endif
