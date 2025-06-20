.PHONY: help install build deploy clean dev

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	flutter pub get
	flutter packages pub run build_runner build --delete-conflicting-outputs

clean: ## Clean build files
	flutter clean
	rm -rf build/ dist/

build: clean ## Build web app for production
	@echo "Building Flutter web app..."
	flutter build web --release --base-href /crimpdeq-app/ --output=dist
	@echo "Adding .nojekyll file..."
	touch dist/.nojekyll
	@echo "Build completed! Files are in dist/"

build-local: clean ## Build web app for local testing
	@echo "Building Flutter web app for local testing..."
	flutter build web --release --output=dist
	@echo "Build completed! Files are in dist/"

dev: ## Run development server
	flutter run -d chrome --web-port 8080

dev-server: ## Run development server (web-server)
	flutter run -d web-server --web-port 8080

deploy: build ## Build and deploy to GitHub Pages
	@echo "Deploying to GitHub Pages..."
	@if [ ! -d ".git" ]; then \
		echo "Error: Not in a git repository"; \
		exit 1; \
	fi
	@if [ -z "$$(git status --porcelain)" ]; then \
		echo "Working directory is clean, proceeding with deployment..."; \
	else \
		echo "Warning: Working directory has uncommitted changes"; \
		read -p "Continue anyway? (y/N): " confirm; \
		if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
			echo "Deployment cancelled"; \
			exit 1; \
		fi; \
	fi
	@echo "Adding dist files to git..."
	git add dist/
	git commit -m "Add dist files for deployment"
	@echo "Deploying using subtree..."
	git subtree push --prefix dist origin gh-pages
	@echo "Deployment completed!"
	@echo "Your app should be available at: https://$$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^/]*\)\.git/\1.github.io\/\2/')"

check: ## Check Flutter and Dart versions
	@echo "Flutter version:"
	@flutter --version
	@echo "\nDart version:"
	@dart --version

setup-pages: ## Setup GitHub Pages (run once)
	@echo "Setting up GitHub Pages..."
	@echo "1. Go to your repository settings on GitHub"
	@echo "2. Navigate to Pages section"
	@echo "3. Set source to 'Deploy from a branch'"
	@echo "4. Select 'gh-pages' branch and '/ (root)' folder"
	@echo "5. Save the settings"
	@echo "6. Run 'make deploy' to deploy your app"

serve-local: build-local ## Serve built app locally
	@echo "Starting local server on http://localhost:8000"
	@echo "Press Ctrl+C to stop"
	cd dist && python3 -m http.server 8000

clean-pages: ## Clean and reset gh-pages branch
	@echo "Cleaning gh-pages branch..."
	@if git show-ref --verify --quiet refs/heads/gh-pages; then \
		git branch -D gh-pages; \
		echo "Local gh-pages branch deleted"; \
	fi
	@if git show-ref --verify --quiet refs/remotes/origin/gh-pages; then \
		git push origin --delete gh-pages; \
		echo "Remote gh-pages branch deleted"; \
	fi
	@echo "gh-pages branch cleaned. Run 'make deploy' to redeploy." 