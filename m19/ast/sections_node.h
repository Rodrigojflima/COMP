#ifndef __M19_SECTIONSNODE_H__
#define __M19_SECTIONSNODE_H__

#include <string>
#include <cdk/ast/expression_node.h>

namespace m19 {
  
  /**
   * Class for describing function_decla nodes.
   */

  class sections_node: public cdk::basic_node {

    cdk::sequence_node *_seq;
    bool _is_inclusive;
    m19::block_node *_block;
    
  public:
    inline sections_node(int lineno, cdk::sequence_node *seq, bool inclusive, m19::block_node *block):
      cdk::basic_node(lineno), _seq(seq), _is_inclusive(inclusive), _block(block) {
      }

  public:
    inline cdk::sequence_node *seq() {
      return _seq;
    }
    inline m19::block_node *block() {
      return _block;
    }
    inline bool is_inclusive() {
      return _is_inclusive;
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_sections_node(this, level);
    }

  };

} // m19

#endif
