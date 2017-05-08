var uniqueId = (function() {
	var id = 0;
	return function() {
		return 'timeline' + id++;
	}
})();

$('.timeline > :has(> h3 a)')
	.addClass('expandable')
	.each(enhanceTimelineLink);

// Register toggling and loading function for linked Gists
$('.timeline .gist')
	.click(function() {
		toggleArticle($(this), function (event, article) {
			loadGist(event, article, event.find('> h3 a').attr('href'))})});

// Register toggling and loading function for linked Github repositories
$('.timeline .repo')
	.click(function() {
		toggleArticle($(this), function (event, article) {
			loadRepo(event, article, event.find('> h3 a').attr('href'))})});

// Register toggling function for simple inlined text
$('.timeline .text')
	.click(function() {
		toggleArticle($(this), loadNothing)});

// Progresive enhancement of links in the timeline: if javascript
// is enabled, fetch the linked information and present it inline
// as hideable details instead of leaving the page after click.
function enhanceTimelineLink(i, item) {
	var timelineItem = $(item);
	var article = timelineItem.find('.article');
	var id;
	if (article.length) {
		id = article.attr('id');
	} else {
		id = uniqueId();
		article = $div('', 'article').attr('id', id);
		timelineItem.append(article);
	}
	article
		.hide()
		.attr('aria-live', 'polite');

	// Make the link appear like a button to assistive technologies
	// by setting the button aria role and emulating button's action keys.
	// Button role is required for the ability to set aria-expanded state and
	// aria-controls property so the assistive technology can understand
	// the meaning of the link as a details visibility switch.
	// The link is already focusable, no need for setting tabindex.
	timelineItem.find('> h3 a')
		.attr('role', 'button')
		.attr('aria-controls', id)
		.attr('aria-expanded', 'false')
		.on("click keydown", function(e) {
			if (e.type == "click" || e.keyCode === 32 || e.keyCode === 13) {
				e.preventDefault();
				e.stopPropagation();
				$(this).closest('li').click();
			}});
}

function loadGist(event, article, url) {
	article.attr('aria-busy', 'true');
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
			article
				.attr('aria-busy', 'false')
				.addClass('loaded');
			event.removeClass('loading');
			showArticle(event, article)});
}

function loadRepo(event, article, url) {
	article.attr('aria-busy', 'true');
	event.addClass('loading');
	githubGet('repos/calaveraInfo/' + extractGithubId(url))
		.then(function(data, status, xhr) {
			githubArticle(article, xhr.responseJSON, 'See the repository');
			return loadRepoReadme(xhr.responseJSON.url, getArticleMenu(article));
		})
		.fail(function() {
			putError(article, url)})
		.always(function(){
			article
				.attr('aria-busy', 'false')
				.addClass('loaded');
			event.removeClass('loading');
			showArticle(event, article)});
}

function loadNothing(event, article) {
	article.addClass('loaded');
	showArticle(event, article);
}

function toggleArticle(event, loadCallback) {
	var article = event.find('.article');
	if (!article.is('.loaded')) {
		loadCallback(event, article);
	} else {
		if (article.is(':visible')) {
			hideArticle(event, article);
		} else {
			showArticle(event, article);
		}
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
			.attr('role', 'list')
			.append($menuItem(response.html_url, linkText, 'external'))]);
}

function showArticle(event, article) {
	article.show(1000);
	event.addClass('expanded');
	event.find('[role="button"]')
		.attr('aria-expanded', 'true');
}

function hideArticle(event, article) {
	article.hide(1000);
	event.removeClass('expanded');
	event.find('[role="button"]')
		.attr('aria-expanded', 'false');
}

function putError(article, url) {
	article.html(
		$p('<i class="fa fa-warning"></i> Data loading error. Please see the <a href="'+url+'">source link</a> yourself.', 'error'));
}

function appendReadmeMenuOption(menu, rendered) {
	menu.append(
		$menuItem('#', 'Show readme file')
			.click(function() {
				$.fancybox.open(
					div(rendered, 'readme'))}));
}

function $menuItem(href, text, classes) {
	return $('<a href="' + href + '" role="listitem" class="list-group-item text-center ' + (classes ? classes : '') + '">' + text + ' </a>');
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