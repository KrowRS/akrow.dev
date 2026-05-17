<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchContent, fetchExtremes, fetchSavages, fetchUltimates, submitEntry } from './lib/api';
  import {
    roleLabels,
    roles,
    type ContentCategoryGroup,
    type ContentResponse,
    type SignupRole
  } from './lib/types';

  const expansions = [
    { id: 'arr', shortName: 'ARR', name: 'A Realm Reborn' },
    { id: 'heavensward', shortName: 'HW', name: 'Heavensward' },
    { id: 'stormblood', shortName: 'SB', name: 'Stormblood' },
    { id: 'shadowbringers', shortName: 'ShB', name: 'Shadowbringers' },
    { id: 'endwalker', shortName: 'EW', name: 'Endwalker' },
    { id: 'dawntrail', shortName: 'DT', name: 'Dawntrail' }
  ];

  let data: ContentResponse | null = null;
  let loading = true;
  let globalError = '';
  let selectedExtremeExpansion = 'dawntrail';
  let selectedSavageExpansion = 'dawntrail';
  let categoryLoading = '';
  let selectedRoles: Record<string, SignupRole | undefined> = {};
  let names: Record<string, string> = {};
  let pendingContentId = '';
  let submitMessages: Record<string, string> = {};

  onMount(async () => {
    await loadContent();
  });

  async function loadContent() {
    loading = true;
    globalError = '';

    try {
      data = await fetchContent(selectedExtremeExpansion, selectedSavageExpansion);
    } catch (error) {
      globalError = error instanceof Error ? error.message : 'Unable to load content.';
    } finally {
      loading = false;
    }
  }

  async function confirm(contentId: string) {
    const ign = names[contentId]?.trim() ?? '';
    const role = selectedRoles[contentId];

    submitMessages = { ...submitMessages, [contentId]: '' };

    if (!ign || !role) {
      submitMessages = { ...submitMessages, [contentId]: 'Enter your IGN and choose a role.' };
      return;
    }

    pendingContentId = contentId;

    try {
      await submitEntry({ contentId, ign, role });
      await refreshContentCategory(contentId);
      names = { ...names, [contentId]: '' };
      submitMessages = { ...submitMessages, [contentId]: 'Saved.' };
    } catch (error) {
      submitMessages = {
        ...submitMessages,
        [contentId]: error instanceof Error ? error.message : 'Unable to save entry.'
      };
    } finally {
      pendingContentId = '';
    }
  }

  async function changeExtremeExpansion(expansionId: string) {
    if (selectedExtremeExpansion === expansionId || categoryLoading) {
      return;
    }

    selectedExtremeExpansion = expansionId;
    categoryLoading = 'extreme_trial';
    globalError = '';

    try {
      const category = await fetchExtremes(expansionId);
      replaceCategory(category);
      if (data) {
        data = { ...data, extremeExpansionId: expansionId };
      }
    } catch (error) {
      globalError = error instanceof Error ? error.message : 'Unable to load extremes.';
    } finally {
      categoryLoading = '';
    }
  }

  async function changeSavageExpansion(expansionId: string) {
    if (selectedSavageExpansion === expansionId || categoryLoading) {
      return;
    }

    selectedSavageExpansion = expansionId;
    categoryLoading = 'savage_raid';
    globalError = '';

    try {
      const category = await fetchSavages(expansionId);
      replaceCategory(category);
      if (data) {
        data = { ...data, savageExpansionId: expansionId };
      }
    } catch (error) {
      globalError = error instanceof Error ? error.message : 'Unable to load savages.';
    } finally {
      categoryLoading = '';
    }
  }

  async function refreshContentCategory(contentId: string) {
    const categoryId = data?.categories.find((category) =>
      category.contents.some((content) => content.id === contentId)
    )?.id;

    if (categoryId === 'extreme_trial') {
      replaceCategory(await fetchExtremes(selectedExtremeExpansion));
      return;
    }

    if (categoryId === 'savage_raid') {
      replaceCategory(await fetchSavages(selectedSavageExpansion));
      return;
    }

    replaceCategory(await fetchUltimates());
  }

  function replaceCategory(category: ContentCategoryGroup) {
    if (!data) {
      return;
    }

    data = {
      ...data,
      categories: data.categories.map((currentCategory) =>
        currentCategory.id === category.id ? category : currentCategory
      )
    };
  }

  function categoryTone(categoryId: string) {
    if (categoryId === 'ultimate') {
      return 'ult';
    }

    if (categoryId === 'extreme_trial') {
      return 'ext';
    }

    return 'sav';
  }
</script>

<svelte:head>
  <title>FFXIV Content Board</title>
</svelte:head>

<main class="site-wrapper">
  <header class="site-header">
    <p class="header-eyebrow">Final Fantasy XIV</p>
    <h1>Content <span>Tracker</span></h1>
    <p class="subtitle">Community Endgame Board</p>
    <div class="legend" aria-label="Content categories">
      <div class="legend-item"><span class="legend-dot ult"></span>Ultimate</div>
      <div class="legend-item"><span class="legend-dot ext"></span>Extreme</div>
      <div class="legend-item"><span class="legend-dot sav"></span>Savage</div>
    </div>
    <button class="refresh-button" type="button" on:click={loadContent} disabled={loading}>
      Refresh
    </button>
  </header>

  {#if loading}
    <section class="state-panel">Loading content...</section>
  {:else if globalError}
    <section class="state-panel error">
      <p>{globalError}</p>
      <button type="button" on:click={loadContent}>Try again</button>
    </section>
  {:else if data}
    <section aria-label="Available content">
      {#each data.categories as category}
        <div class="category-block">
          <div class={`section-label ${categoryTone(category.id)}`}>
            <span>{category.name}</span>
          </div>
          <div class="category-heading">
            {#if category.id === 'extreme_trial'}
              <div class="expansion-tabs" role="tablist" aria-label="Extreme trial expansion">
                {#each expansions as expansion}
                  <button
                    type="button"
                    role="tab"
                    aria-selected={selectedExtremeExpansion === expansion.id}
                    class:active={selectedExtremeExpansion === expansion.id}
                    disabled={categoryLoading !== ''}
                    title={expansion.name}
                    on:click={() => changeExtremeExpansion(expansion.id)}
                  >
                    {expansion.shortName}
                  </button>
                {/each}
              </div>
            {:else if category.id === 'savage_raid'}
              <div class="expansion-tabs" role="tablist" aria-label="Savage raid expansion">
                {#each expansions as expansion}
                  <button
                    type="button"
                    role="tab"
                    aria-selected={selectedSavageExpansion === expansion.id}
                    class:active={selectedSavageExpansion === expansion.id}
                    disabled={categoryLoading !== ''}
                    title={expansion.name}
                    on:click={() => changeSavageExpansion(expansion.id)}
                  >
                    {expansion.shortName}
                  </button>
                {/each}
              </div>
            {/if}
          </div>
          {#if categoryLoading === category.id}
            <p class="category-status">Loading {category.name.toLowerCase()}...</p>
          {/if}
          <div class="card-grid">
            {#each category.contents as content}
              <article class={`content-card ${categoryTone(category.id)}`}>
                <div class="card-top-bar"></div>
                <div class="card-body">
                  <div class="card-badge">
                    {#if category.id === 'ultimate'}
                      Ultimate
                    {:else if category.id === 'extreme_trial'}
                      Extreme Trial
                    {:else}
                      Savage
                    {/if}
                  </div>
                  <div class="card-title-row">
                  <div>
                    <h4>{content.name}</h4>
                    {#if content.shortName}
                      <p>{content.shortName}</p>
                    {/if}
                  </div>
                </div>

                <div class="role-control" aria-label={`Role for ${content.name}`}>
                  {#each roles as role}
                    <button
                      type="button"
                      class={role}
                      class:active={selectedRoles[content.id] === role}
                      aria-pressed={selectedRoles[content.id] === role}
                      on:click={() => (selectedRoles = { ...selectedRoles, [content.id]: role })}
                    >
                      {roleLabels[role]}
                    </button>
                  {/each}
                </div>

                <div class="submit-row">
                  <input
                    aria-label={`In-game username for ${content.name}`}
                    placeholder="In-game username"
                    bind:value={names[content.id]}
                    maxlength="64"
                  />
                  <button
                    class="confirm-btn"
                    type="button"
                    on:click={() => confirm(content.id)}
                    disabled={pendingContentId === content.id}
                  >
                    {pendingContentId === content.id ? 'Saving' : 'Confirm'}
                  </button>
                </div>

                {#if submitMessages[content.id]}
                  <p class:error={submitMessages[content.id] !== 'Saved.'} class="submit-message">
                    {submitMessages[content.id]}
                  </p>
                {/if}

                <div class="entry-groups">
                  {#each roles as role}
                    <section class={`${role}-col`}>
                      <div class={`entry-heading ${role}`}>
                        <strong>{roleLabels[role]}</strong>
                        <span>{content.entries[role].length}</span>
                      </div>
                      {#if content.entries[role].length}
                        <ul>
                          {#each content.entries[role] as entry}
                            <li class={role}>{entry.ign}</li>
                          {/each}
                        </ul>
                      {:else}
                        <p class="empty-list">No entries</p>
                      {/if}
                    </section>
                  {/each}
                </div>
                </div>
              </article>
            {/each}
          </div>
        </div>
      {/each}
    </section>
    <footer>
      <p>FINAL FANTASY XIV ENDGAME TRACKER · COMMUNITY BOARD</p>
      <p>Data is shared publicly. All characters are visible to all visitors.</p>
    </footer>
  {/if}
</main>
