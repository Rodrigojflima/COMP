#ifndef __M19_FORNODE_H__
#define __M19_FORNODE_H__

#include <cdk/ast/sequence_node.h>
#include <cdk/ast/lvalue_node.h>

namespace m19 {

  /**
   * Class for describing for cicles nodes.
   */

  class for_node: public cdk::basic_node {
  protected:
  	cdk::sequence_node *_begin;
  	cdk::sequence_node *_end;
  	cdk::sequence_node *_increment;
  	cdk::basic_node *_instruction;

  public:
	inline for_node(int lineno, cdk::sequence_node *begin, cdk::sequence_node *end,
		          cdk::sequence_node *increment, cdk::basic_node *instruction) :
			cdk::basic_node(lineno), _begin(begin), _end(end), _increment(increment), _instruction(instruction) {
	}

  public:
  	inline cdk::sequence_node *begin(){
  		return _begin;
  	}

	inline cdk::sequence_node *end(){
		return _end;
	}

	inline cdk::sequence_node *increment(){
		return _increment;
	}
		
	inline cdk::basic_node *instruction(){
		return _instruction;
	}

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_for_node(this, level);
    }

  };

} // m19

#endif
