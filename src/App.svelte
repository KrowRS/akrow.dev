<script lang="ts">
  import { onMount } from 'svelte';
  import { fetchContent, fetchExtremes, fetchSavages, fetchUltimates, submitEntries } from './lib/api';
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
  let masterName = '';
  let editMode = false;
  let draftRoles: Record<string, SignupRole | undefined> = {};
  let dirtyContentIds = new Set<string>();
  let dirtySelectionCount = 0;
  let savePending = false;
  let saveMessage = '';

  onMount(async () => {
    await loadContent();
  });

  async function loadContent() {
    loading = true;
    globalError = '';

    try {
      data = await fetchContent(selectedExtremeExpansion, selectedSavageExpansion);
      syncVisibleSelections();
    } catch (error) {
      globalError = error instanceof Error ? error.message : 'Unable to load content.';
    } finally {
      loading = false;
    }
  }

  function handleNameInput(value: string) {
    masterName = value;
    editMode = false;
    draftRoles = {};
    dirtyContentIds = new Set();
    dirtySelectionCount = 0;
    saveMessage = '';
    syncVisibleSelections();
  }

  function startEditMode() {
    if (!masterName.trim()) {
      saveMessage = 'Enter your character name before editing.';
      return;
    }

    syncVisibleSelections();
    editMode = true;
    saveMessage = '';
  }

  function cancelEditMode() {
    editMode = false;
    draftRoles = {};
    dirtyContentIds = new Set();
    dirtySelectionCount = 0;
    syncVisibleSelections();
    saveMessage = '';
  }

  function selectRole(contentId: string, role: SignupRole) {
    if (!editMode) {
      return;
    }

    draftRoles = { ...draftRoles, [contentId]: role };
    dirtyContentIds = new Set(dirtyContentIds).add(contentId);
    dirtySelectionCount = dirtyContentIds.size;
    saveMessage = '';
  }

  async function saveDraft() {
    const ign = masterName.trim();
    const entries = Object.entries(draftRoles)
      .filter(([, role]) => Boolean(role))
      .map(([contentId, role]) => ({ contentId, role: role as SignupRole }));

    if (!ign) {
      saveMessage = 'Enter your character name before saving.';
      return;
    }

    if (entries.length === 0) {
      saveMessage = 'Choose at least one role before saving.';
      return;
    }

    savePending = true;
    saveMessage = '';

    try {
      await submitEntries({ ign, entries });
      await refreshLoadedCategories();
      dirtyContentIds = new Set();
      dirtySelectionCount = 0;
      editMode = false;
      saveMessage = 'Saved.';
    } catch (error) {
      saveMessage = error instanceof Error ? error.message : 'Unable to save entries.';
    } finally {
      savePending = false;
    }
  }

  async function refreshLoadedCategories() {
    const categories = await Promise.all([
      fetchUltimates(),
      fetchExtremes(selectedExtremeExpansion),
      fetchSavages(selectedSavageExpansion)
    ]);

    if (data) {
      data = { ...data, categories };
      syncVisibleSelections();
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

    syncCategorySelections(category);
  }

  function syncVisibleSelections() {
    if (!data || !masterName.trim()) {
      return;
    }

    for (const category of data.categories) {
      syncCategorySelections(category);
    }
  }

  function syncCategorySelections(category: ContentCategoryGroup) {
    if (!masterName.trim()) {
      return;
    }

    const nextRoles = { ...draftRoles };

    for (const content of category.contents) {
      if (dirtyContentIds.has(content.id)) {
        continue;
      }

      const existingRole = findRoleForName(content.entries);
      if (existingRole) {
        nextRoles[content.id] = existingRole;
      } else {
        delete nextRoles[content.id];
      }
    }

    draftRoles = nextRoles;
  }

  function findRoleForName(entries: ContentCategoryGroup['contents'][number]['entries']) {
    const normalizedName = normalizeName(masterName);

    if (!normalizedName) {
      return undefined;
    }

    return roles.find((role) =>
      entries[role].some((entry) => normalizeName(entry.ign) === normalizedName)
    );
  }

  function normalizeName(value: string) {
    return value.trim().replace(/\s+/g, ' ').toLowerCase();
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

  <section class="profile-panel" aria-label="Character profile">
    <div class="profile-field">
      <label for="master-name">Character Name</label>
      <input
        id="master-name"
        value={masterName}
        placeholder="Enter character name"
        maxlength="64"
        disabled={editMode || savePending}
        on:input={(event) => handleNameInput(event.currentTarget.value)}
      />
    </div>
    <div class="profile-actions">
      {#if editMode}
        <button class="profile-btn secondary" type="button" on:click={cancelEditMode} disabled={savePending}>
          Cancel
        </button>
        <button
          class="profile-btn primary"
          type="button"
          on:click={saveDraft}
          disabled={savePending}
        >
          {savePending ? 'Saving' : 'Save'}
        </button>
      {:else}
        <button class="profile-btn primary" type="button" on:click={startEditMode} disabled={!masterName.trim()}>
          Edit
        </button>
      {/if}
    </div>
    {#if saveMessage}
      <p class:error={saveMessage !== 'Saved.'} class="profile-message">{saveMessage}</p>
    {/if}
  </section>

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
                      class:active={draftRoles[content.id] === role}
                      aria-pressed={draftRoles[content.id] === role}
                      disabled={!editMode || savePending}
                      on:click={() => selectRole(content.id, role)}
                    >
                      {roleLabels[role]}
                    </button>
                  {/each}
                </div>

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
