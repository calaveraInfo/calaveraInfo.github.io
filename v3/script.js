$('.timeline .gist')
	.click(function() {
		toggleArticle($(this), function (event, article) {
			loadGist(event, article, event.find('> h3 a').attr('href'))})});

$('.timeline .repo')
	.click(function() {
		toggleArticle($(this), function (event, article) {
			loadRepo(event, article, event.find('> h3 a').attr('href'))})});

$('.timeline .text')
	.click(function() {
		toggleArticle($(this), function(){})});

$('.timeline .gist > h3 a, .timeline .repo > h3 a')
	.click(function (e) {
		e.preventDefault()});

function loadGist(event, article, url) {
	event.addClass('loading');
	githubGet('gists/' + extractGithubId(url))
		.then(function(data, status, xhr) {
			githubArticle(article, xhr.responseJSON, 'See the Gist');
			if (xhr.responseJSON.files["README.md"]) {
				return loadRawReadme(xhr.responseJSON.files["README.md"].content, getArticleMenu(article));
			}
		})
		.fail(function() {
			putError(article, url)})
		.always(function(){
			showArticle(event, article)});
}

function loadRepo(event, article, url) {
	event.addClass('loading');
	githubGet('repos/calaveraInfo/' + extractGithubId(url))
		.then(function(data, status, xhr) {
			githubArticle(article, xhr.responseJSON, 'See the repository');
			return loadRepoReadme(xhr.responseJSON.url, getArticleMenu(article));
		})
		.fail(function() {
			putError(article, url)})
		.always(function(){
			showArticle(event, article)});
}

function toggleArticle(event, creationCallback) {
	var article = event.find('.article');
	if (article.length) {
		article.toggle(1000);
		event.toggleClass('expanded');
	} else {
		article = $div('', 'article').hide();
		event.append(article);
		creationCallback(event, article);
	}
}

function loadRawReadme(rawMarkdown, menu) {
	return $.post({
		url: 'https://api.github.com/markdown/raw',
		contentType: 'text/x-markdown',
		data: rawMarkdown
	}).done(function(rendered) {
		appendReadmeMenuOption(menu, rendered)});
}

function loadRepoReadme(repoUrl, menu) {
	return $.get({
		url: repoUrl + '/readme',
		accepts: { html: 'application/vnd.github.VERSION.html' },
		dataType: 'html'
	}).done(function (rendered) {
		appendReadmeMenuOption(menu, rendered)});
}

function getArticleMenu(article) {
	return article.find('.list-group');
}

function extractGithubId(url) {
	return url.substr(url.lastIndexOf('/')+1);
}

function githubGet(url) {
	return $.get({url: 'https://api.github.com/' + url, dataType: 'json'});
}

function githubArticle(article, response, linkText) {
	article.html([
		$p(response.description),
		$div('', 'list-group')
			.append($menuItem(response.html_url, linkText, 'external'))]);
}

function showArticle(event, article) {
	article.show(1000);
	event.addClass('expanded');
	event.removeClass('loading');
}

function putError(article, url) {
	article.html(
		$p('<i class="fa fa-warning"></i> Data loading error.', 'error'));
}

function appendReadmeMenuOption(menu, rendered) {
	menu.append(
		$menuItem('#', 'Show readme file')
			.click(function() {
				$.fancybox.open(
					div(rendered, 'readme'))}));
}

function $menuItem(href, text, classes) {
	return $('<a href="' + href + '" class="list-group-item text-center ' + (classes ? classes : '') + '">' + text + ' </a>');
}

function $p(content, classes) {
	return $('<p class="' + (classes ? classes : '') + '">' + content + '</p>');
}

function $div(content, classes) {
	return $(div(content, classes));
}

function div(content, classes) {
	return '<div class="' + (classes ? classes : '') + '">' + content + '</div>';
}