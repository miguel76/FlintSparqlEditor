
/*

SPARQL 1.0 grammar rules based on the ones here:
  http://www.w3.org/TR/rdf-sparql-query/

Be careful with grammar notation - it's EBNF in prolog syntax!

[...] lists always represent sequence.
or can be used as binary operator or nary prefix term - don't put [...] inside
   unless you want sequence as a single disjunct.

*, +, ? - generally used as 1-ary terms 

*/

s ==> [query,$].

query ==> 
	[prologue,or(selectQuery,constructQuery,describeQuery,askQuery), valuesClause].

prologue ==> 
	[*(baseDecl or prefixDecl)].

baseDecl ==> 
	['BASE','IRI_REF'].

prefixDecl ==> 
	['PREFIX','PNAME_NS','IRI_REF'].
selectQuery ==> 
	[selectClause, *(datasetClause),whereClause,solutionModifier].
subSelect ==> [selectClause, whereClause, solutionModifier, valuesClause].
selectClause ==>
	['SELECT',
	?('DISTINCT' or 'REDUCED'),
	(+(var or (['(', expression, 'AS', var, ')'])) or '*')].
constructQuery ==> 
	['CONSTRUCT',
	(([constructTemplate,*(datasetClause),whereClause,solutionModifier]) or 
	([*(datasetClause), 'WHERE', '{', ?(triplesTemplate), '}', solutionModifier]))].
describeQuery ==> 
	['DESCRIBE',+(varOrIri) or '*',
	*(datasetClause),?(whereClause),solutionModifier].
askQuery ==>
	['ASK',*(datasetClause),whereClause,solutionModifier].
datasetClause ==> 
	['FROM',defaultGraphClause or namedGraphClause]. 
defaultGraphClause ==> 
	[sourceSelector].
namedGraphClause ==> 
	['NAMED',sourceSelector].
sourceSelector ==> 
	[iri].
whereClause ==> 
	[?('WHERE'),groupGraphPattern].
solutionModifier ==> 
	[?(groupClause),?(havingClause),?(orderClause),?(limitOffsetClauses)].
groupClause ==>
	['GROUP', 'BY', +(groupCondition)].
groupCondition ==>
	[builtInCall].
groupCondition ==>
	[functionCall].
groupCondition ==>
	[var].	
groupCondition ==>
	['(',expression, ?(['AS',var]), ')'].
havingClause ==>
	['HAVING', +(havingCondition)].
havingCondition ==> 
	[constraint].
orderClause ==> 
	['ORDER','BY',+(orderCondition)].
orderCondition ==> 
	['ASC' or 'DESC',brackettedExpression].
orderCondition ==> 
	[constraint].
orderCondition ==> 
	[var].
limitOffsetClauses ==> 
	[(([limitClause, ?(offsetClause)]) or ([offsetClause, ?(limitClause)]))].
limitClause ==> 
	['LIMIT','INTEGER'].
offsetClause ==> 
	['OFFSET','INTEGER'].
valuesClause ==> [?([ 'VALUES', dataBlock ])].
update ==> 
	[prologue, ?([update1, ?([';', update])])].
update1 ==>
	[load, clear, drop, add, move, copy, create, insertData, deleteData, deleteWhere, modify].
load ==>
	['LOAD', ?('SILENT'), iri, ?(['INTO', graphRef])].
clear ==>
	['CLEAR', ?('SILENT'), graphRefAll].
drop ==>
	['DROP', ?('SILENT'), graphRefAll].
create ==>
	['CREATE', ?('SILENT'), graphRef].
add ==> 
	['ADD', ?('SILENT'), graphOrDefault, 'TO', graphOrDefault].
move ==> 
	['MOVE', ?('SILENT'), graphOrDefault, 'TO', graphOrDefault].
copy ==> 
	['COPY', ?('SILENT'), graphOrDefault, 'TO', graphOrDefault].
insertData ==>
	['INSERT', 'DATA', quadData].
deleteData ==>
	['DELETE', 'DATA', quadData].
deleteWhere ==>
	['DELETE', 'WHERE', quadPattern].
modify ==>
	[?(['WITH', iri]), 
	([deleteClause, ?(insertClause)] or insertClause),
	*(usingClause), 'WHERE', groupGraphPattern].	
deleteClause ==>
	['DELETE', quadPattern].
insertClause ==>
	['INSERT', quadPattern].
usingClause ==>
	['USING', (iri or ['NAMED', iri])].
graphOrDefault ==> 
	[('DEFAULT' or [?('GRAPH'), iri])].
graphRef ==>
	['GRAPH', iri].
graphRefAll ==>
	[(graphRef or 'DEFAULT' or 'NAMED' or 'ALL')].
quadPattern ==>
	['{', quads, '}'].
quadData ==>
	['{', quads, '}'].
quads ==>
	[?(triplesTemplate), *([quadsNotTriples, ?('.'), ?(triplesTemplate)])].
quadsNotTriples ==>
	['GRAPH', varOrIri, '{', ?(triplesTemplate), '}'].
triplesTemplate ==>
	[triplesSameSubject, ?(['.', ?(triplesTemplate)])].
groupGraphPattern ==>
	['{', (subSelect or groupGraphPatternSub), '}'].
groupGraphPatternSub ==>
	[?(triplesBlock), *([graphPatternNotTriples, ?('.'), ?(triplesBlock)])].
triplesBlock ==>
	[triplesSameSubjectPath, ?(['.', ?(triplesBlock)])].
graphPatternNotTriples ==>
	[(groupOrUnionGraphPattern or optionalGraphPattern or minusGraphPattern or graphGraphPattern or serviceGraphPattern or filter or bind or inlineData)].
optionalGraphPattern ==> 
	['OPTIONAL',groupGraphPattern].
graphGraphPattern ==> 
	['GRAPH',varOrIri,groupGraphPattern].
serviceGraphPattern ==>
	['SERVICE', ?('SILENT'), varOrIri, groupGraphPattern].
bind ==>
	['BIND', '(', expression, 'AS', var, ')'].
inlineData ==>
	['VALUES', dataBlock].
dataBlock ==> [(inlineDataOneVar or inlineDataFull)].
inlineDataOneVar ==> [var, '{', *(dataBlockValue), '}'].
inlineDataFull ==> 
	['NIL' or ['(', *(var), ')'], '{', *(['(', *(dataBlockValue), ')'] or 'NIL'), '}'].
dataBlockValue ==> 
	[(iri or rdfLiteral or numericLiteral or booleanLiteral or 'UNDEF' )].
minusGraphPattern ==>
	['MINUS', groupGraphPattern].
groupOrUnionGraphPattern ==> 
	[groupGraphPattern,*(['UNION',groupGraphPattern])].
filter ==> 
	['FILTER',constraint].
constraint ==> 
	[brackettedExpression].
constraint ==> 
	[builtInCall].
constraint ==> 
	[functionCall].
functionCall ==> 
	[iri,argList].
argList ==> 
	['NIL'].
argList ==> 
	['(',expression,*([',',expression]),')'].
expressionList ==> 
	[('NIL' or ['(', expression, *([',', expression]), ')'])].
constructTemplate ==>
	['{',?(constructTriples),'}'].
constructTriples ==>
	[triplesSameSubject,?(['.',?(constructTriples)])].
triplesSameSubject ==>
	[([varOrTerm,propertyListNotEmpty] or [triplesNode, propertyList])].
propertyList ==> 
	[?(propertyListNotEmpty)].
propertyListNotEmpty ==> 
	[verb,objectList,*([';',?([verb,objectList])])].
verb ==> 
	[(varOrIri or 'a')].
objectList ==> 
	[object,*([',',object])].
object ==> 
	[graphNode].
triplesSameSubjectPath ==>
	[([varOrTerm, propertyListPathNotEmpty] or [triplesNodePath, propertyListPath])].
propertyListPath ==> 
	[?(propertyListPathNotEmpty)].
propertyListPathNotEmpty ==> 
	[(verbPath or verbSimple), objectListPath, *([';', ?([(verbPath or verbSimple), objectList])])].
verbPath ==> 
	[path].
verbSimple ==> 
	[var].
objectListPath ==>
	[objectPath, *([',', objectPath])].
objectPath ==>
	[graphNodePath].
path ==>
	[pathAlternative].
pathAlternative ==>
	[pathSequence, *(['|', pathSequence])].
pathSequence ==>
	[pathEltOrInverse, *(['/', pathEltOrInverse])].
pathElt ==>
	[pathPrimary, ?(pathMod)].
pathEltOrInverse ==>
	[(pathElt or ['^', pathElt])].
pathMod ==>
	[('?' or '*' or '+')].
pathPrimary ==> 
	[(iri or 'a' or (['!', pathNegatedPropertySet]) or (['(', path, ')']) or (['DISTINCT', '(', path, ')']))].
pathNegatedPropertySet ==> 
	[pathOneInPropertySet or ['(', ?([pathOneInPropertySet, *(['|', pathOneInPropertySet])]),')']].
pathOneInPropertySet ==>
	[(iri or 'a' or ['^', (iri or 'a')])].
triplesNode ==> [(collection or blankNodePropertyList)].
blankNodePropertyList ==> 
	['[',propertyListNotEmpty,']'].
triplesNodePath ==>
	[(collectionPath or blankNodePropertyListPath)].
blankNodePropertyListPath ==>
	['[', propertyListPathNotEmpty, ']'].
collection ==> 
	['(',+(graphNode),')'].
collectionPath ==>
	['(', +(graphNodePath), ')'].
graphNode ==> [varOrTerm].
graphNode ==> [triplesNode].
graphNodePath ==> 
	[(varOrTerm or triplesNodePath)].
varOrTerm ==> [var].
varOrTerm ==> [graphTerm].
varOrIri ==> [var].
varOrIri ==> [iri].
var ==> ['VAR1'].
var ==> ['VAR2'].
graphTerm ==> [iri].
graphTerm ==> [rdfLiteral].
graphTerm ==> [numericLiteral].
graphTerm ==> [booleanLiteral].
graphTerm ==> [blankNode].
graphTerm ==> ['NIL'].
expression ==> 
	[conditionalOrExpression].
conditionalOrExpression ==> 
	[conditionalAndExpression,*(['||',conditionalAndExpression])].
conditionalAndExpression ==>
	[valueLogical,*(['&&',valueLogical])].
valueLogical ==>
	[relationalExpression].
relationalExpression ==>
	[numericExpression,
	?(or( ['=',numericExpression], 
	      ['!=',numericExpression],
	      ['<',numericExpression],
	      ['>',numericExpression],
	      ['<=',numericExpression],
	      ['>=',numericExpression],
	      ['IN',expressionList],
	      ['NOT', 'IN', expressionList]
	    ))].
numericExpression ==>
	[additiveExpression].
additiveExpression ==>
	[multiplicativeExpression,
	*(['+',multiplicativeExpression] or
	['-',multiplicativeExpression] or
	[(numericLiteralPositive or
	numericLiteralNegative)
	,*(['*', unaryExpression ] or ['/', unaryExpression])])].
multiplicativeExpression ==>
	[unaryExpression,
	  *( ['*',unaryExpression] 
            or 
             ['/',unaryExpression] )].
unaryExpression ==>
	[or( ['!',primaryExpression],
	     ['+',primaryExpression],
	     ['-',primaryExpression],
	     primaryExpression ) ].
primaryExpression ==> [brackettedExpression].
primaryExpression ==> [builtInCall].
primaryExpression ==> [iriOrFunction].
primaryExpression ==> [rdfLiteral].
primaryExpression ==> [numericLiteral].
primaryExpression ==> [booleanLiteral].
primaryExpression ==> [var].
brackettedExpression ==> ['(',expression,')'].
builtInCall ==> [aggregate].
builtInCall ==> ['STR','(',expression,')'].
builtInCall ==> ['LANG','(',expression,')'].
builtInCall ==> ['LANGMATCHES','(',expression, ',', expression, ')'].
builtInCall ==> ['DATATYPE','(',expression,')'].
builtInCall ==> ['BOUND','(',expression,')'].
builtInCall ==> ['IRI','(',expression,')'].
builtInCall ==> ['URI','(',expression,')'].
builtInCall ==> ['BNODE', (['(',expression,')'] or 'NIL')].
builtInCall ==> ['RAND','NIL'].
builtInCall ==> ['ABS','(',expression,')'].
builtInCall ==> ['CEIL','(',expression,')'].
builtInCall ==> ['FLOOR','(',expression,')'].
builtInCall ==> ['ROUND','(',expression,')'].
builtInCall ==> ['CONCAT',expressionList].
builtInCall ==> [substringExpression].
builtInCall ==> ['STRLEN','(',expression,')'].
builtInCall ==> [strReplaceExpression].
builtInCall ==> ['UCASE','(',expression,')'].
builtInCall ==> ['LCASE','(',expression,')'].
builtInCall ==> ['ENCODE_FOR_URI','(',expression,')'].
builtInCall ==> ['CONTAINS','(',expression, ',', expression, ')'].
builtInCall ==> ['STRSTARTS','(',expression, ',', expression, ')'].
builtInCall ==> ['STRENDS','(',expression, ',', expression, ')'].
builtInCall ==> ['STRBEFORE','(',expression, ',', expression, ')'].
builtInCall ==> ['STRAFTER','(',expression, ',', expression, ')'].
builtInCall ==> ['YEAR','(',expression,')'].
builtInCall ==> ['MONTH','(',expression,')'].
builtInCall ==> ['DAY','(',expression,')'].
builtInCall ==> ['HOURS','(',expression,')'].
builtInCall ==> ['MINUTES','(',expression,')'].
builtInCall ==> ['SECONDS','(',expression,')'].
builtInCall ==> ['TIMEZONE','(',expression,')'].
builtInCall ==> ['TZ','(',expression,')'].
builtInCall ==> ['NOW', 'NIL'].
builtInCall ==> ['UUID', 'NIL'].
builtInCall ==> ['STRUUID', 'NIL'].
builtInCall ==> ['MD5','(',expression,')'].
builtInCall ==> ['SHA1','(',expression,')'].
builtInCall ==> ['SHA256','(',expression,')'].
builtInCall ==> ['SHA384','(',expression,')'].
builtInCall ==> ['SHA512','(',expression,')'].
builtInCall ==> ['COALESCE', expressionList].
builtInCall ==> ['IF', '(', expression,',', expression, ',', expression, ')'].
builtInCall ==> ['STRLANG', '(', expression,',', expression, ')'].
builtInCall ==> ['STRDT', '(', expression,',', expression, ')'].
builtInCall ==> ['SAMETERM', '(', expression,',', expression, ')'].
builtInCall ==> ['ISURI', '(', expression, ')'].
builtInCall ==> ['ISIRI', '(', expression, ')'].
builtInCall ==> ['ISBLANK', '(', expression, ')'].
builtInCall ==> ['ISLITERAL', '(', expression, ')'].
builtInCall ==> ['ISNUMERIC', '(', expression, ')'].
builtInCall ==> [regexExpression].
builtInCall ==> [existsFunc].
builtInCall ==> [notExistsFunc].

regexExpression ==> 
	['REGEX','(',expression,',',expression,	?([',',expression]),')'].
substringExpression ==>
	['SUBSTR', '(', expression, ',', expression, ?([',', expression]), ')'].
strReplaceExpression ==>
	['REPLACE', '(', expression, ',', expression, ',', expression, ?([',', expression]), ')'].
existsFunc ==>
	['EXISTS', groupGraphPattern].
notExistsFunc ==>
	['NOT', 'EXISTS', groupGraphPattern].
aggregate ==> ['COUNT', '(', ?('DISTINCT'), '*' or expression, ')'].
aggregate ==> ['SUM', '(', ?('DISTINCT'), expression, ')'].
aggregate ==> ['MIN', '(', ?('DISTINCT'), expression, ')'].
aggregate ==> ['MAX', '(', ?('DISTINCT'), expression, ')'].
aggregate ==> ['AVG', '(', ?('DISTINCT'), expression, ')'].
aggregate ==> ['SAMPLE', '(', ?('DISTINCT'), expression, ')'].
aggregate ==> ['GROUP_CONCAT', '(', ?('DISTINCT'), expression, ?([';', 'SEPARATOR', '=', string]), ')'].
iriOrFunction ==> [iri,?(argList)].
rdfLiteral ==> [string,?('LANGTAG' or (['^^',iri]))].
numericLiteral ==> [numericLiteralUnsigned].
numericLiteral ==> [numericLiteralPositive].
numericLiteral ==> [numericLiteralNegative].
numericLiteralUnsigned ==> ['INTEGER'].
numericLiteralUnsigned ==> ['DECIMAL'].
numericLiteralUnsigned ==> ['DOUBLE'].
numericLiteralPositive ==> ['INTEGER_POSITIVE'].
numericLiteralPositive ==> ['DECIMAL_POSITIVE'].
numericLiteralPositive ==> ['DOUBLE_POSITIVE'].
numericLiteralNegative ==> ['INTEGER_NEGATIVE'].
numericLiteralNegative ==> ['DECIMAL_NEGATIVE'].
numericLiteralNegative ==> ['DOUBLE_NEGATIVE'].
booleanLiteral ==> ['TRUE'].
booleanLiteral ==> ['FALSE'].
string ==> ['STRING_LITERAL1'].
string ==> ['STRING_LITERAL2'].
string ==> ['STRING_LITERAL_LONG1'].
string ==> ['STRING_LITERAL_LONG2'].
iri ==> ['IRI_REF'].
iri ==> [prefixedName].
prefixedName ==> ['PNAME_LN'].
prefixedName ==> ['PNAME_NS'].
blankNode ==> ['BLANK_NODE_LABEL'].
blankNode ==> ['ANON'].


% tokens defined by regular expressions elsewhere
tm_regex([
'IRI_REF',
'VAR1',
'VAR2',
'LANGTAG',
'DOUBLE',
'DECIMAL',
'INTEGER',
'DOUBLE_POSITIVE',
'DECIMAL_POSITIVE',
'INTEGER_POSITIVE',
'INTEGER_NEGATIVE',
'DECIMAL_NEGATIVE',
'DOUBLE_NEGATIVE',
'STRING_LITERAL_LONG1',
'STRING_LITERAL_LONG2',
'STRING_LITERAL1',
'STRING_LITERAL2',
'NIL',
'ANON',
'PNAME_LN',
'PNAME_NS',
'BLANK_NODE_LABEL'
]).


% Terminals where name of terminal is uppercased token content
tm_keywords([
'REPLACE',
'INTO',
'LOAD',
'CLEAR',
'DROP',
'CREATE',
'MOVE',
'COPY',
'INSERT',
'DATA',
'DELETE',
'WITH',
'USING',
'DEFAULT',
'BNODE',
'RAND',
'ABS',
'CEIL',
'FLOOR',
'ROUND',
'CONCAT',
'STRLEN',
'UCASE',
'LCASE',
'ENCODE_FOR_URI',
'CONTAINS',
'STRSTARTS',
'STRENDS',
'STRBEFORE',
'STRAFTER',
'YEAR',
'MONTH',
'DAY',
'HOURS',
'MINUTES',
'SECONDS',
'TIMEZONE',
'UUID',
'STRUUID',
'MD5',
'SHA512',
'SHA384',
'SHA256',
'SHA1',
'COALESCE',
'STRLANG',
'STRDT',
'ISNUMERIC',
'SUBSTR',
'EXISTS',
'VALUES',
'BIND',
'UNDEF',
'SERVICE',
'SILENT',
'MINUS',
'COUNT',
'SUM',
'MIN',
'MAX',
'AVG',
'SAMPLE',
'GROUP_CONCAT',
'SEPARATOR',
'GROUP',
'BASE',
'PREFIX',
'SELECT',
'CONSTRUCT',
'DESCRIBE',
'ASK',
'FROM',
'NAMED',
'ORDER',
'BY',
'LIMIT',
'ASC',
'DESC',
'OFFSET',
'DISTINCT',
'REDUCED',
'WHERE',
'GRAPH',
'OPTIONAL',
'UNION',
'FILTER',
'STR',
'LANG',
'LANGMATCHES',
'DATATYPE',
'BOUND',
'SAMETERM',
'ISIRI',
'ISURI',
'ISBLANK',
'ISLITERAL',
'REGEX',
'TRUE',
'FALSE',
'IRI',
'URI',
'AS',
'TO',
'IN',
'NOT',
'ADD',
'NOW',
'ALL',
'TZ',
'HAVING',
'IF'
]).

% Other tokens representing fixed, case sensitive, strings
% Care! order longer tokens first - e.g. IRI_REF, <=, <
% e.g. >=, >
% e.g. NIL, '('
% e.g. ANON, [
% e.g. DOUBLE, DECIMAL, INTEGER
% e.g. INTEGER_POSITIVE, PLUS
tm_punct([
'?' = '\\?',
'*'= '\\*',
'a'= 'a',
'.'= '\\.',
'{'= '\\{',
'}'= '\\}',
','= ',',
'('= '\\(',
')'= '\\)',
';'= ';',
'['= '\\[',
']'= '\\]',
'||'= '\\|\\|',
'|'= '\\|',
'&&'= '&&',
'='= '=',
'!='= '!=',
'!'= '!',
'<='= '<=',
'>='= '>=',
'<'= '<',
'>'= '>',
'+'= '\\+',
'-'= '-',
'/'= '\\/',
'^^'= '\\^\\^',
'^' = '\\^'
]).
