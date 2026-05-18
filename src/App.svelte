<script lang="ts">
  import { onMount } from 'svelte';
  import {
    fetchContent,
    fetchDeepDungeonProgress,
    fetchExtremes,
    fetchSavages,
    fetchUltimates,
    saveDeepDungeonProgress,
    submitEntries
  } from './lib/api';
  import {
    roleLabels,
    roles,
    type ContentCategoryGroup,
    type ContentResponse,
    type DeepDungeonRow,
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

  type DeepDungeonValueKey = 'heaven' | 'eureka' | 'pilgrims';

  const deepDungeonStorageKey = 'deep-dungeon-progress';

  const defaultDeepDungeonRows: DeepDungeonRow[] = [
    { name: 'Astrid', palace: false, heaven: '1', eureka: '1', pilgrims: '1' },
    { name: 'Avery', palace: true, heaven: '1', eureka: '0', pilgrims: '2' },
    { name: 'Bari', palace: false, heaven: '4', eureka: '4', pilgrims: '' },
    { name: 'Corvus', palace: false, heaven: '', eureka: '', pilgrims: '' },
    { name: 'Eli', palace: false, heaven: '', eureka: '', pilgrims: '' },
    { name: 'Ellix', palace: true, heaven: '4', eureka: '', pilgrims: '' },
    { name: 'Frosty', palace: true, heaven: '4', eureka: '4', pilgrims: '' },
    { name: 'Hanabi', palace: true, heaven: '4', eureka: '0', pilgrims: '3' },
    { name: 'Kirby', palace: true, heaven: '4', eureka: '4', pilgrims: '8' },
    { name: 'Krippy', palace: false, heaven: '', eureka: '', pilgrims: '' },
    { name: 'Lhei', palace: true, heaven: '4', eureka: '1', pilgrims: '1' },
    { name: 'Luna', palace: false, heaven: '', eureka: '', pilgrims: '' },
    { name: 'Mateen', palace: false, heaven: '', eureka: '', pilgrims: '' },
    { name: 'Preto', palace: true, heaven: '2', eureka: '2', pilgrims: '' },
    { name: 'Raova', palace: true, heaven: '3', eureka: '', pilgrims: '' },
    { name: 'Selene', palace: true, heaven: '2', eureka: '', pilgrims: '' },
    { name: 'Selicia', palace: true, heaven: '4', eureka: '2', pilgrims: '' },
    { name: 'Shark', palace: false, heaven: '', eureka: '', pilgrims: '' },
    { name: 'Tiri', palace: true, heaven: '4', eureka: '4', pilgrims: '8' },
    { name: 'Yen', palace: false, heaven: '4', eureka: '', pilgrims: '' }
  ];

  const deepDungeonColumns = [
    { key: 'palace', label: 'Palace of the Dead' },
    { key: 'heaven', label: 'Heaven on High' },
    { key: 'eureka', label: 'Eureka Orthos' },
    { key: 'pilgrims', label: "Pilgrim's Traverse" }
  ] as const;

  type UserContentStatus = {
    contentId: string;
    contentName: string;
    contentShortName: string | null;
    categoryName: string;
    role: SignupRole | undefined;
  };

  let deepDungeonRows = defaultDeepDungeonRows.map((row) => ({ ...row }));
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
  let deepDungeonSaveMessage = '';
  let selectedUserName = '';
  let selectedUserContentStatuses: UserContentStatus[] = [];

  onMount(async () => {
    await loadDeepDungeonRows();
    await loadContent();
  });

  async function loadDeepDungeonRows() {
    try {
      const savedRows = await fetchDeepDungeonProgress();
      deepDungeonRows = savedRows.length ? savedRows : defaultDeepDungeonRows.map((row) => ({ ...row }));
      cacheDeepDungeonRows(deepDungeonRows);
      return;
    } catch {
      deepDungeonSaveMessage = 'Using locally cached sheet data.';
    }

    const savedRows = localStorage.getItem(deepDungeonStorageKey);

    if (!savedRows) {
      return;
    }

    try {
      const parsedRows = JSON.parse(savedRows);

      if (Array.isArray(parsedRows)) {
        deepDungeonRows = parsedRows.map((row, index) => ({
          ...defaultDeepDungeonRows[index],
          ...row,
          name: String(row.name ?? defaultDeepDungeonRows[index]?.name ?? ''),
          palace: Boolean(row.palace),
          heaven: String(row.heaven ?? ''),
          eureka: String(row.eureka ?? ''),
          pilgrims: String(row.pilgrims ?? '')
        }));
      }
    } catch {
      localStorage.removeItem(deepDungeonStorageKey);
    }
  }

  function cacheDeepDungeonRows(rows: DeepDungeonRow[]) {
    localStorage.setItem(deepDungeonStorageKey, JSON.stringify(rows));
  }

  async function saveDeepDungeonRows(rows: DeepDungeonRow[]) {
    cacheDeepDungeonRows(rows);
    deepDungeonSaveMessage = 'Saving sheet...';

    try {
      await saveDeepDungeonProgress(rows);
      deepDungeonSaveMessage = 'Sheet saved.';
    } catch (error) {
      deepDungeonSaveMessage =
        error instanceof Error ? error.message : 'Unable to save sheet to Supabase.';
    }
  }

  function updateDeepDungeonName(rowIndex: number, value: string) {
    deepDungeonRows = deepDungeonRows.map((row, index) =>
      index === rowIndex ? { ...row, name: value } : row
    );
    void saveDeepDungeonRows(deepDungeonRows);
  }

  function toggleDeepDungeonPalace(rowIndex: number) {
    deepDungeonRows = deepDungeonRows.map((row, index) =>
      index === rowIndex ? { ...row, palace: !row.palace } : row
    );
    void saveDeepDungeonRows(deepDungeonRows);
  }

  function updateDeepDungeonValue(rowIndex: number, key: DeepDungeonValueKey, value: string) {
    deepDungeonRows = deepDungeonRows.map((row, index) =>
      index === rowIndex ? { ...row, [key]: value.trim() } : row
    );
    void saveDeepDungeonRows(deepDungeonRows);
  }

  function addDeepDungeonUser() {
    deepDungeonRows = [
      ...deepDungeonRows,
      { name: '', palace: false, heaven: '', eureka: '', pilgrims: '' }
    ];
    void saveDeepDungeonRows(deepDungeonRows);
  }

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

  function openUserModal(name: string) {
    selectedUserName = name;
    selectedUserContentStatuses = getUserLearnerOrMissingContent(name);
  }

  function closeUserModal() {
    selectedUserName = '';
    selectedUserContentStatuses = [];
  }

  function handleWindowKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape' && selectedUserName) {
      closeUserModal();
    }
  }

  function handleModalBackdropClick(event: MouseEvent) {
    if (event.target === event.currentTarget) {
      closeUserModal();
    }
  }

  function getUserLearnerOrMissingContent(name: string) {
    const normalizedName = normalizeName(name);

    if (!data || !normalizedName) {
      return [];
    }

    const statuses: UserContentStatus[] = [];

    for (const category of data.categories) {
      for (const content of category.contents) {
        const role = roles.find((currentRole) =>
          content.entries[currentRole].some((entry) => normalizeName(entry.ign) === normalizedName)
        );

        if (role === 'learner' || !role) {
          statuses.push({
            contentId: content.id,
            contentName: content.name,
            contentShortName: content.shortName,
            categoryName: category.name,
            role
          });
        }
      }
    }

    return statuses;
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

  function progressTone(value: string, key: DeepDungeonValueKey) {
    if (!value) {
      return 'missing';
    }

    if (value === '0') {
      return 'danger';
    }

    if ((key === 'heaven' || key === 'eureka') && value === '4') {
      return 'cleared';
    }

    if (key === 'pilgrims' && value === '8') {
      return 'cleared';
    }

    return 'partial';
  }
</script>

<svelte:head>
  <title>FFXIV Content Board</title>
</svelte:head>

<svelte:window on:keydown={handleWindowKeydown} />

<main class="site-wrapper">
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

  <header class="site-header">
    <h1>Comfy Content <span>Tracker</span></h1>
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
                    {expansion.name}
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
                    {expansion.name}
                  </button>
                {/each}
              </div>
            {/if}
          </div>
          {#if categoryLoading === category.id}
            <p class="category-status">Loading {category.name.toLowerCase()}...</p>
          {/if}
          <div class="card-grid" class:loading={categoryLoading === category.id}>
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
                            <li class={role}>
                              <button
                                class="entry-name-btn"
                                type="button"
                                on:click={() => openUserModal(entry.ign)}
                              >
                                {entry.ign}
                              </button>
                            </li>
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
    <section class="deep-dungeon-section" aria-label="Deep dungeon progress">
      <div class="section-label deep">
        <span>Deep Dungeon Progress</span>
      </div>
      <div class="deep-table-panel">
        <div class="deep-table-scroll">
          <table class="deep-table">
            <thead>
              <tr>
                <th scope="col">Character</th>
                {#each deepDungeonColumns as column}
                  <th scope="col">{column.label}</th>
                {/each}
              </tr>
            </thead>
            <tbody>
              {#each deepDungeonRows as row, rowIndex}
                <tr>
                  <th scope="row">
                    <input
                      class="deep-name-input"
                      value={row.name}
                      aria-label="Character name"
                      maxlength="64"
                      on:input={(event) => updateDeepDungeonName(rowIndex, event.currentTarget.value)}
                    />
                  </th>
                  <td class:cleared={row.palace} class:missing={!row.palace}>
                    <button
                      class="check-box"
                      type="button"
                      aria-pressed={row.palace}
                      aria-label={row.palace ? 'Mark Palace of the Dead incomplete' : 'Mark Palace of the Dead cleared'}
                      on:click={() => toggleDeepDungeonPalace(rowIndex)}
                    >
                      {row.palace ? '✓' : ''}
                    </button>
                  </td>
                  <td class={progressTone(row.heaven, 'heaven')}>
                    <input
                      class="deep-cell-input"
                      value={row.heaven}
                      aria-label={`${row.name} Heaven on High progress`}
                      maxlength="8"
                      on:input={(event) => updateDeepDungeonValue(rowIndex, 'heaven', event.currentTarget.value)}
                    />
                  </td>
                  <td class={progressTone(row.eureka, 'eureka')}>
                    <input
                      class="deep-cell-input"
                      value={row.eureka}
                      aria-label={`${row.name} Eureka Orthos progress`}
                      maxlength="8"
                      on:input={(event) => updateDeepDungeonValue(rowIndex, 'eureka', event.currentTarget.value)}
                    />
                  </td>
                  <td class={progressTone(row.pilgrims, 'pilgrims')}>
                    <input
                      class="deep-cell-input"
                      value={row.pilgrims}
                      aria-label={`${row.name} Pilgrim's Traverse progress`}
                      maxlength="8"
                      on:input={(event) => updateDeepDungeonValue(rowIndex, 'pilgrims', event.currentTarget.value)}
                    />
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </div>
      <div class="deep-table-actions">
        <button class="deep-add-btn" type="button" on:click={addDeepDungeonUser}>
          Add User
        </button>
      </div>
      {#if deepDungeonSaveMessage}
        <p class="deep-save-message">{deepDungeonSaveMessage}</p>
      {/if}
    </section>
    {#if selectedUserName}
      <div class="modal-backdrop" role="presentation" on:click={handleModalBackdropClick}>
        <div
          class="user-modal"
          role="dialog"
          aria-modal="true"
          aria-labelledby="user-modal-title"
          tabindex="-1"
        >
          <div class="user-modal-header">
            <div>
              <p>Character</p>
              <h2 id="user-modal-title">{selectedUserName}</h2>
            </div>
            <button class="modal-close-btn" type="button" aria-label="Close user content modal" on:click={closeUserModal}>
              ×
            </button>
          </div>
          {#if selectedUserContentStatuses.length}
            <ul class="user-content-list">
              {#each selectedUserContentStatuses as status}
                <li class:learner-missing={!status.role}>
                  <div>
                    <strong>{status.contentName}</strong>
                    {#if status.contentShortName}
                      <span>{status.contentShortName}</span>
                    {/if}
                    <small>{status.categoryName}</small>
                  </div>
                  <em>{status.role ? roleLabels[status.role] : 'No role listed'}</em>
                </li>
              {/each}
            </ul>
          {:else}
            <p class="user-modal-empty">No learner or unlisted content found.</p>
          {/if}
        </div>
      </div>
    {/if}
    <footer>
      <p>If anything breaks bother Avery</p>
    </footer>
  {/if}
</main>
