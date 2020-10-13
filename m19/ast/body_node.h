#ifndef __M19_BODYNODE_H__
#define __M19_BODYNODE_H__

#include <string>
#include <cdk/ast/expression_node.h>


namespace m19 {
  
  /**
   * Class for describing body nodes.
   */

  class body_node: public cdk::basic_node {

    m19::block_node *_initBlock;
    cdk::sequence_node *_sections;
    m19::block_node *_endBlock;

  public:
    inline body_node(int lineno, m19::block_node *initBlock, cdk::sequence_node *sections, m19::block_node *endBlock):
      cdk::basic_node(lineno), _initBlock(initBlock), _sections(sections), _endBlock(endBlock) {
	}

  public:
    inline m19::block_node *initBlock() {
      return _initBlock;
    }
    inline cdk::sequence_node *sections() {
      return _sections;
    }
    inline m19::block_node *endBlock() {
      return _endBlock;
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_body_node(this, level);
    }

  };

} // m19

#endif
