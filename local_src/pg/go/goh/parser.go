package main

import (
	"fmt"
	"os"
)

// AST Node types
type NodeTermIntLit struct {
	IntLit Token
}

type NodeTermIdent struct {
	Ident Token
}

type NodeTermParen struct {
	Expr *NodeExpr
}

type NodeBinExprAdd struct {
	Lhs *NodeExpr
	Rhs *NodeExpr
}

type NodeBinExprMulti struct {
	Lhs *NodeExpr
	Rhs *NodeExpr
}

type NodeBinExprSub struct {
	Lhs *NodeExpr
	Rhs *NodeExpr
}

type NodeBinExprDiv struct {
	Lhs *NodeExpr
	Rhs *NodeExpr
}

type NodeBinExpr struct {
	Var interface{} // One of: *NodeBinExprAdd, *NodeBinExprMulti, *NodeBinExprSub, *NodeBinExprDiv
}

type NodeTerm struct {
	Var interface{} // One of: *NodeTermIntLit, *NodeTermIdent, *NodeTermParen
}

type NodeExpr struct {
	Var interface{} // One of: *NodeTerm, *NodeBinExpr
}

type NodeStmtExit struct {
	Expr *NodeExpr
}

type NodeStmtLet struct {
	Ident Token
	Expr  *NodeExpr
}

type NodeScope struct {
	Stmts []*NodeStmt
}

type NodeIfPredElif struct {
	Expr  *NodeExpr
	Scope *NodeScope
	Pred  *NodeIfPred
}

type NodeIfPredElse struct {
	Scope *NodeScope
}

type NodeIfPred struct {
	Var interface{} // One of: *NodeIfPredElif, *NodeIfPredElse
}

type NodeStmtIf struct {
	Expr  *NodeExpr
	Scope *NodeScope
	Pred  *NodeIfPred
}

type NodeStmtAssign struct {
	Ident Token
	Expr  *NodeExpr
}

type NodeStmt struct {
	Var interface{} // One of: *NodeStmtExit, *NodeStmtLet, *NodeScope, *NodeStmtIf, *NodeStmtAssign
}

type NodeProg struct {
	Stmts []*NodeStmt
}

type Parser struct {
	tokens    []Token
	index     int
	allocator *ArenaAllocator
}

func NewParser(tokens []Token) *Parser {
	return &Parser{
		tokens:    tokens,
		index:     0,
		allocator: NewArenaAllocator(1024 * 1024 * 4), // 4 MB
	}
}

func (p *Parser) errorExpected(msg string) {
	token := p.peek(-1)
	line := 0
	if token != nil {
		line = token.Line
	}
	fmt.Fprintf(os.Stderr, "[Parse Error] Expected %s on line %d\n", msg, line)
	os.Exit(1)
}

func (p *Parser) parseTerm() *NodeTerm {
	if intLit := p.tryConsume(TokenIntLit); intLit != nil {
		termIntLit, _ := Emplace(p.allocator, NodeTermIntLit{IntLit: *intLit})
		term, _ := Emplace(p.allocator, NodeTerm{Var: termIntLit})
		return term
	}

	if ident := p.tryConsume(TokenIdent); ident != nil {
		exprIdent, _ := Emplace(p.allocator, NodeTermIdent{Ident: *ident})
		term, _ := Emplace(p.allocator, NodeTerm{Var: exprIdent})
		return term
	}

	if openParen := p.tryConsume(TokenOpenParen); openParen != nil {
		expr := p.parseExpr(0)
		if expr == nil {
			p.errorExpected("expression")
		}
		p.tryConsumeErr(TokenCloseParen)
		termParen, _ := Emplace(p.allocator, NodeTermParen{Expr: expr})
		term, _ := Emplace(p.allocator, NodeTerm{Var: termParen})
		return term
	}

	return nil
}

func (p *Parser) parseExpr(minPrec int) *NodeExpr {
	termLhs := p.parseTerm()
	if termLhs == nil {
		return nil
	}
	exprLhs, _ := Emplace(p.allocator, NodeExpr{Var: termLhs})

	for {
		currTok := p.peek(0)
		var prec int
		var hasPrec bool
		if currTok != nil {
			prec, hasPrec = BinPrec(currTok.Type)
			if !hasPrec || prec < minPrec {
				break
			}
		} else {
			break
		}

		token := p.consume()
		nextMinPrec := prec + 1
		exprRhs := p.parseExpr(nextMinPrec)
		if exprRhs == nil {
			p.errorExpected("expression")
		}

		expr, _ := Emplace(p.allocator, NodeBinExpr{})
		exprLhs2, _ := Emplace(p.allocator, NodeExpr{})

		if token.Type == TokenPlus {
			exprLhs2.Var = exprLhs.Var
			add, _ := Emplace(p.allocator, NodeBinExprAdd{Lhs: exprLhs2, Rhs: exprRhs})
			expr.Var = add
		} else if token.Type == TokenStar {
			exprLhs2.Var = exprLhs.Var
			multi, _ := Emplace(p.allocator, NodeBinExprMulti{Lhs: exprLhs2, Rhs: exprRhs})
			expr.Var = multi
		} else if token.Type == TokenMinus {
			exprLhs2.Var = exprLhs.Var
			sub, _ := Emplace(p.allocator, NodeBinExprSub{Lhs: exprLhs2, Rhs: exprRhs})
			expr.Var = sub
		} else if token.Type == TokenFslash {
			exprLhs2.Var = exprLhs.Var
			div, _ := Emplace(p.allocator, NodeBinExprDiv{Lhs: exprLhs2, Rhs: exprRhs})
			expr.Var = div
		} else {
			panic("Unreachable")
		}
		exprLhs.Var = expr
	}
	return exprLhs
}

func (p *Parser) parseScope() *NodeScope {
	if p.tryConsume(TokenOpenCurly) == nil {
		return nil
	}

	scope, _ := Emplace(p.allocator, NodeScope{})
	for {
		stmt := p.parseStmt()
		if stmt == nil {
			break
		}
		scope.Stmts = append(scope.Stmts, stmt)
	}
	p.tryConsumeErr(TokenCloseCurly)
	return scope
}

func (p *Parser) parseIfPred() *NodeIfPred {
	if p.tryConsume(TokenElif) != nil {
		p.tryConsumeErr(TokenOpenParen)
		elif := &NodeIfPredElif{}

		if expr := p.parseExpr(0); expr != nil {
			elif.Expr = expr
		} else {
			p.errorExpected("expression")
		}

		p.tryConsumeErr(TokenCloseParen)
		if scope := p.parseScope(); scope != nil {
			elif.Scope = scope
		} else {
			p.errorExpected("scope")
		}

		elif.Pred = p.parseIfPred()
		pred, _ := Emplace(p.allocator, NodeIfPred{Var: elif})
		return pred
	}

	if p.tryConsume(TokenElse) != nil {
		else_ := &NodeIfPredElse{}
		if scope := p.parseScope(); scope != nil {
			else_.Scope = scope
		} else {
			p.errorExpected("scope")
		}
		pred, _ := Emplace(p.allocator, NodeIfPred{Var: else_})
		return pred
	}

	return nil
}

func (p *Parser) parseStmt() *NodeStmt {
	if p.peek(0) != nil && p.peek(0).Type == TokenExit && p.peek(1) != nil && p.peek(1).Type == TokenOpenParen {
		p.consume()
		p.consume()
		stmtExit, _ := Emplace(p.allocator, NodeStmtExit{})
		if nodeExpr := p.parseExpr(0); nodeExpr != nil {
			stmtExit.Expr = nodeExpr
		} else {
			p.errorExpected("expression")
		}
		p.tryConsumeErr(TokenCloseParen)
		p.tryConsumeErr(TokenSemi)
		stmt, _ := Emplace(p.allocator, NodeStmt{})
		stmt.Var = stmtExit
		return stmt
	}

	if p.peek(0) != nil && p.peek(0).Type == TokenLet && p.peek(1) != nil && p.peek(1).Type == TokenIdent && p.peek(2) != nil && p.peek(2).Type == TokenEq {
		p.consume()
		stmtLet, _ := Emplace(p.allocator, NodeStmtLet{})
		stmtLet.Ident = p.consume()
		p.consume()
		if expr := p.parseExpr(0); expr != nil {
			stmtLet.Expr = expr
		} else {
			p.errorExpected("expression")
		}
		p.tryConsumeErr(TokenSemi)
		stmt, _ := Emplace(p.allocator, NodeStmt{})
		stmt.Var = stmtLet
		return stmt
	}

	if p.peek(0) != nil && p.peek(0).Type == TokenIdent && p.peek(1) != nil && p.peek(1).Type == TokenEq {
		assign := &NodeStmtAssign{}
		assign.Ident = p.consume()
		p.consume()
		if expr := p.parseExpr(0); expr != nil {
			assign.Expr = expr
		} else {
			p.errorExpected("expression")
		}
		p.tryConsumeErr(TokenSemi)
		stmt, _ := Emplace(p.allocator, NodeStmt{Var: assign})
		return stmt
	}

	if p.peek(0) != nil && p.peek(0).Type == TokenOpenCurly {
		if scope := p.parseScope(); scope != nil {
			stmt, _ := Emplace(p.allocator, NodeStmt{Var: scope})
			return stmt
		}
		p.errorExpected("scope")
	}

	if p.tryConsume(TokenIf) != nil {
		p.tryConsumeErr(TokenOpenParen)
		stmtIf, _ := Emplace(p.allocator, NodeStmtIf{})
		if expr := p.parseExpr(0); expr != nil {
			stmtIf.Expr = expr
		} else {
			p.errorExpected("expression")
		}
		p.tryConsumeErr(TokenCloseParen)
		if scope := p.parseScope(); scope != nil {
			stmtIf.Scope = scope
		} else {
			p.errorExpected("scope")
		}
		stmtIf.Pred = p.parseIfPred()
		stmt, _ := Emplace(p.allocator, NodeStmt{Var: stmtIf})
		return stmt
	}

	return nil
}

func (p *Parser) ParseProg() (NodeProg, bool) {
	prog := NodeProg{}
	for p.peek(0) != nil {
		if stmt := p.parseStmt(); stmt != nil {
			prog.Stmts = append(prog.Stmts, stmt)
		} else {
			p.errorExpected("statement")
		}
	}
	return prog, true
}

func (p *Parser) peek(offset int) *Token {
	if p.index+offset >= len(p.tokens) {
		return nil
	}
	return &p.tokens[p.index+offset]
}

func (p *Parser) consume() Token {
	token := p.tokens[p.index]
	p.index++
	return token
}

func (p *Parser) tryConsumeErr(tokenType TokenType) Token {
	if p.peek(0) != nil && p.peek(0).Type == tokenType {
		return p.consume()
	}
	p.errorExpected(tokenType.String())
	return Token{}
}

func (p *Parser) tryConsume(tokenType TokenType) *Token {
	if p.peek(0) != nil && p.peek(0).Type == tokenType {
		token := p.consume()
		return &token
	}
	return nil
}