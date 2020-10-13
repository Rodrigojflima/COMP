#ifndef __M19_FUNCTIONDECLANODE_H__
#define __M19_FUNCTIONDECLANODE_H__

#include <string>
#include <cdk/ast/sequence_node.h>
#include <cdk/basic_type.h>

namespace m19 {
  
  /**
   * Class for describing function_decla nodes.
   */

  class function_decla_node: public cdk::basic_node {
    basic_type *_type;
    bool _public;
    bool _ext;
    std::string *_id;
    cdk::sequence_node *_args;
    
  public:
    inline function_decla_node(int lineno, basic_type *type, bool is_public, bool is_ext, std::string *id, cdk::sequence_node *args):
      cdk::basic_node(lineno), _type(type), _public(is_public), _ext(is_ext),  _id(id), _args(args) {
	}

  public:
    inline basic_type *type() {
      return _type;
    }
    inline bool is_public() {
      return _public;
    }
    inline bool is_ext() {
      return _ext;
    }
    inline std::string *id() {
      return _id;
    }
    inline cdk::sequence_node *args() {
      return _args;
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_decla_node(this, level);
    }

  };

} // m19

#endif
