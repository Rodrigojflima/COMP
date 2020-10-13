#ifndef __M19_FUNCTIONDEFINITIONNODE_H__
#define __M19_FUNCTIONDEFINITIONNODE_H__

#include <string>
#include <cdk/ast/basic_node.h>
#include <cdk/basic_type.h> /* <cdk/ast/typed_node.h */
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include "ast/block_node.h"

namespace m19 {

  /**
   * Class for describing function definitions.
   */
  class function_definition_node: public cdk::basic_node {
    basic_type *_type; /*cdk::typed_node*/
    std::string _id;
    bool _public;
    cdk::sequence_node *_args;
    cdk::expression_node *_value;
    m19::body_node *_body; /*sections_node*/

  public:
    inline function_definition_node(int lineno, basic_type* type, const std::string *id, bool is_public, cdk::sequence_node *args, cdk::expression_node *value, m19::body_node *body) :
        cdk::basic_node(lineno), _type(type), _id(*id), _public(is_public), _args(args), _value(value), _body(body) {
    }

  public:
    inline basic_type *type() {
      return _type;
    }

    inline const std::string id() {
      return _id;
    }
    
    inline bool is_public() {
      return _public;
    }
    
    inline cdk::sequence_node *args() {
      return _args;
    }
    
    inline cdk::expression_node *value() {
      return _value;
    }

    inline m19::body_node *body() {
      return _body;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_definition_node(this, level);
    }

  };

} // m19

#endif
