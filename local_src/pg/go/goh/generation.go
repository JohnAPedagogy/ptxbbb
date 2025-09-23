package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Var struct {
	Name     string
	StackLoc int
}

type Generator struct {
	prog        NodeProg
	output      strings.Builder
	stackSize   int
	vars        []Var
	scopes      []int
	labelCount  int
}

func NewGenerator(prog NodeProg) *Generator {
	return &Generator{
		prog:       prog,
		stackSize:  0,
		vars:       make([]Var, 0),
		scopes:     make([]int, 0),
		labelCount: 0,
	}
}

func (g *Generator) genTerm(term *NodeTerm) {
	switch v := term.Var.(type) {
	case *NodeTermIntLit:
		g.output.WriteString("    mov rax, " + *v.IntLit.Value + "\n")
		g.push("rax")
	case *NodeTermIdent:
		found := false
		var stackLoc int
		for _, variable := range g.vars {
			if variable.Name == *v.Ident.Value {
				stackLoc = variable.StackLoc
				found = true
				break
			}
		}
		if !found {
			fmt.Fprintf(os.Stderr, "Undeclared identifier: %s\n", *v.Ident.Value)
			os.Exit(1)
		}
		offset := fmt.Sprintf("QWORD [rsp + %d]", (g.stackSize-stackLoc-1)*8)
		g.push(offset)
	case *NodeTermParen:
		g.genExpr(v.Expr)
	}
}

func (g *Generator) genBinExpr(binExpr *NodeBinExpr) {
	switch v := binExpr.Var.(type) {
	case *NodeBinExprSub:
		g.genExpr(v.Rhs)
		g.genExpr(v.Lhs)
		g.pop("rax")
		g.pop("rbx")
		g.output.WriteString("    sub rax, rbx\n")
		g.push("rax")
	case *NodeBinExprAdd:
		g.genExpr(v.Rhs)
		g.genExpr(v.Lhs)
		g.pop("rax")
		g.pop("rbx")
		g.output.WriteString("    add rax, rbx\n")
		g.push("rax")
	case *NodeBinExprMulti:
		g.genExpr(v.Rhs)
		g.genExpr(v.Lhs)
		g.pop("rax")
		g.pop("rbx")
		g.output.WriteString("    mul rbx\n")
		g.push("rax")
	case *NodeBinExprDiv:
		g.genExpr(v.Rhs)
		g.genExpr(v.Lhs)
		g.pop("rax")
		g.pop("rbx")
		g.output.WriteString("    div rbx\n")
		g.push("rax")
	}
}

func (g *Generator) genExpr(expr *NodeExpr) {
	switch v := expr.Var.(type) {
	case *NodeTerm:
		g.genTerm(v)
	case *NodeBinExpr:
		g.genBinExpr(v)
	}
}

func (g *Generator) genScope(scope *NodeScope) {
	g.beginScope()
	for _, stmt := range scope.Stmts {
		g.genStmt(stmt)
	}
	g.endScope()
}

func (g *Generator) genIfPred(pred *NodeIfPred, endLabel string) {
	switch v := pred.Var.(type) {
	case *NodeIfPredElif:
		g.output.WriteString("    ;; elif\n")
		g.genExpr(v.Expr)
		g.pop("rax")
		label := g.createLabel()
		g.output.WriteString("    test rax, rax\n")
		g.output.WriteString("    jz " + label + "\n")
		g.genScope(v.Scope)
		g.output.WriteString("    jmp " + endLabel + "\n")
		if v.Pred != nil {
			g.output.WriteString(label + ":\n")
			g.genIfPred(v.Pred, endLabel)
		}
	case *NodeIfPredElse:
		g.output.WriteString("    ;; else\n")
		g.genScope(v.Scope)
	}
}

func (g *Generator) genStmt(stmt *NodeStmt) {
	switch v := stmt.Var.(type) {
	case *NodeStmtExit:
		g.output.WriteString("    ;; exit\n")
		g.genExpr(v.Expr)
		g.output.WriteString("    mov rax, 60\n")
		g.pop("rdi")
		g.output.WriteString("    syscall\n")
		g.output.WriteString("    ;; /exit\n")
	case *NodeStmtLet:
		g.output.WriteString("    ;; let\n")
		for _, variable := range g.vars {
			if variable.Name == *v.Ident.Value {
				fmt.Fprintf(os.Stderr, "Identifier already used: %s\n", *v.Ident.Value)
				os.Exit(1)
			}
		}
		g.vars = append(g.vars, Var{Name: *v.Ident.Value, StackLoc: g.stackSize})
		g.genExpr(v.Expr)
		g.output.WriteString("    ;; /let\n")
	case *NodeStmtAssign:
		found := false
		var stackLoc int
		for i, variable := range g.vars {
			if variable.Name == *v.Ident.Value {
				stackLoc = variable.StackLoc
				found = true
				break
			}
		}
		if !found {
			fmt.Fprintf(os.Stderr, "Undeclared identifier: %s\n", *v.Ident.Value)
			os.Exit(1)
		}
		g.genExpr(v.Expr)
		g.pop("rax")
		g.output.WriteString(fmt.Sprintf("    mov [rsp + %d], rax\n", (g.stackSize-stackLoc-1)*8))
	case *NodeScope:
		g.output.WriteString("    ;; scope\n")
		g.genScope(v)
		g.output.WriteString("    ;; /scope\n")
	case *NodeStmtIf:
		g.output.WriteString("    ;; if\n")
		g.genExpr(v.Expr)
		g.pop("rax")
		label := g.createLabel()
		g.output.WriteString("    test rax, rax\n")
		g.output.WriteString("    jz " + label + "\n")
		g.genScope(v.Scope)
		if v.Pred != nil {
			endLabel := g.createLabel()
			g.output.WriteString("    jmp " + endLabel + "\n")
			g.output.WriteString(label + ":\n")
			g.genIfPred(v.Pred, endLabel)
			g.output.WriteString(endLabel + ":\n")
		} else {
			g.output.WriteString(label + ":\n")
		}
		g.output.WriteString("    ;; /if\n")
	}
}

func (g *Generator) GenProg() string {
	g.output.WriteString("global _start\n_start:\n")

	for _, stmt := range g.prog.Stmts {
		g.genStmt(stmt)
	}

	g.output.WriteString("    mov rax, 60\n")
	g.output.WriteString("    mov rdi, 0\n")
	g.output.WriteString("    syscall\n")
	return g.output.String()
}

func (g *Generator) push(reg string) {
	g.output.WriteString("    push " + reg + "\n")
	g.stackSize++
}

func (g *Generator) pop(reg string) {
	g.output.WriteString("    pop " + reg + "\n")
	g.stackSize--
}

func (g *Generator) beginScope() {
	g.scopes = append(g.scopes, len(g.vars))
}

func (g *Generator) endScope() {
	popCount := len(g.vars) - g.scopes[len(g.scopes)-1]
	if popCount != 0 {
		g.output.WriteString(fmt.Sprintf("    add rsp, %d\n", popCount*8))
	}
	g.stackSize -= popCount
	for i := 0; i < popCount; i++ {
		g.vars = g.vars[:len(g.vars)-1]
	}
	g.scopes = g.scopes[:len(g.scopes)-1]
}

func (g *Generator) createLabel() string {
	label := "label" + strconv.Itoa(g.labelCount)
	g.labelCount++
	return label
}