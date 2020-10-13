#ifndef __M19_VARDECLANODE_H__
#define __M19_VARDECLANODE_H__

#include <string>
#include <cdk/ast/basic_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/basic_type.h>

namespace m19 {

  
  class var_decla_node: public cdk::basic_node {
    basic_type *_type;
    bool _public;
    bool _ext;
    std::string *_id;
    cdk::expression_node *_init;

  public:
    inline var_decla_node(int lineno, basic_type *type, bool is_public, bool is_ext, std::string *id, cdk::expression_node *init) :
        cdk::basic_node(lineno), _type(type), _public(is_public), _ext(is_ext), _id(id), _init(init) {
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
    inline cdk::expression_node *init() {
      return _init;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_var_decla_node(this, level);
    }

  };

} // m19

#endif
