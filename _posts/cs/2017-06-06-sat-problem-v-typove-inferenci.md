---
title: SAT problém v typové inferenci
---

Věděli jste, že Java generika mohou pro kompilátor představovat SAT problém? A že v důsledku toho může být čas kompilace exponenciální? Mě by to ani nenapadlo do chvíle, kdy jsem začal zjišťovat proč build jednoho z našich menších modulů trvá abnormálních pět minut.

Hlavní podezřelý byl jasný, protože to byl jediný modul, kde jsem ve velkém použil v testech [Hamcrest][hamcrest] matchery a build mrznul právě při kompilaci testů. Ano, při kompilaci! Chápal bych, kdyby build zdržoval běh špatně napsaných testů, ale kompilace? Jak se vlastně debuguje kompilátor?

Protože jsem rozhodně nechtěl buildovat vlastní OpenJDK, zkusil jsem to nejdřív intuicí. Ta mi napovídala, že problém se bude nějak týkat jednoho mého vlastního matcheru, který ‎matchoval zadaný atribut objektu generického typu. Hamcrest nabízí [podobný matcher][property matcher], ale ten není silně typový a mně připadalo, že by to s generiky a lambdami šlo napsat mnohem lépe. A taky že ano:

{% highlight java %}

public class MyMatcher<T, U> extends BaseMatcher<T>{
	private Function<T, U> getter;
	private Matcher<U> matcher;

	public MyMatcher(Function<T, U> getter, Matcher<U> matcher) {
		this.getter = getter;
		this.matcher = matcher;
	}

 public boolean matches(Object item) {
 	return matcher.matches(getter.apply((T) item));
 }

 public static <T, U> Matcher<T> attribute(Function<T, U> getter, Matcher<U> matcher) {
 	return new MyMatcher<T, U>(getter, matcher);
 }

{% endhighlight %}

S tímto matcherem šlo ‎validovat košaté a hluboké objektové stromy bez jakýchkoli pomocných proměnných, cyklů nebo nekonečných getter řetězů a nullchecků. Všechny typové informace ze zachovávaly v postupně se zanořujícím kontextu volání mého matcheru, takže refaktoring a jiné výhody typového systému zůstaly zachované i‎ v testech:

{% highlight java %}

@Test
public void testApp() {
	Foo foo = new Foo();
	foo.setText("ahoj");
	Bar bar = new Bar();
	bar.setText("nazdar");
	foo.setBar(bar);
	assertThat(foo, allOf(
			attribute(Foo::getBar,
					attribute(Bar::getText, is("nazdar"))),
			attribute(Foo::getText, is("ahoj"))));
}

{% endhighlight %}

Obzvlášť si všimněte, jak je použití matcheru ‎úsporné a elegantní díky inferenci generik u návratového typu zanořovaných funkcí. Ale to se bohužel ukázalo jako onen‎ kámen úrazu. Chvilka googlování odhalila, že [nejsem sám, kdo má s inferencí generik ve složitých výrazech problém][stackoverflow]. A že už je na to v JDK založen [issue][bug], resp. několik příbuzných issue.

[Rozšíření inference i na návratové typy je poměrně nová featura Javy‎][pricina], takže by člověk předpokládal, že to je jen nedospělostí implementace a chyba bude brzy opravena, ale ono je to složitější. Klíč k pochopení leží v kapitole "Dependencies" odkazovaného JEPu:

> This work depends on the Project Lambda JEP -- Project Lambda requires a novel way of type-inference, called target-typing inference, that is used to infer the type of the formals of a lambda expression from the context in which the lambda expression is used. Part of this work <u>(inference in method context) is simply a generalization of the approach exploited in project lambda</u>.

Převzetím strategie inference z lambd totiž Java přebrala  i její problémy, které hezky polopatě popsali přátelé z .NET: [Aby kompilátor mohl inferovat datový typ, musí vyřešit SAT problém][dot net]. [Turing-úplnost typového systému tedy není bug, ale feature][turing]. Tomu říkám hustokrutopřísnost.

Jojo, [Java nám dospívá][generics] a začíná se potýkat s problémy dospělosti.

[hamcrest]: http://hamcrest.org/
[property matcher]: http://hamcrest.org/JavaHamcrest/javadoc/1.3/org/hamcrest/Matchers.html#hasProperty(java.lang.String, org.hamcrest.Matcher)
[dot net]: https://blogs.msdn.microsoft.com/ericlippert/2007/03/28/lambda-expressions-vs-anonymous-methods-part-five/
[bug]: https://bugs.openjdk.java.net/browse/JDK-8046685‎
[stackoverflow]: https://stackoverflow.com/questions/30707387/troubleshoot-slow-compilation/30736467#30736467
[pricina]: http://openjdk.java.net/jeps/101
[generics]: https://arxiv.org/abs/1605.05274
[turing]: https://www.quora.com/What-does-it-mean-to-say-that-a-type-system-is-Turing-complete
