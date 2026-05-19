<script lang="ts">
  import { onMount } from 'svelte';
  import {
    fetchContent,
    fetchDeepDungeonProgress,
    fetchExtremes,
    fetchMountProgress,
    fetchSavages,
    fetchUltimates,
    saveDeepDungeonProgress,
    saveMountProgress,
    submitEntries
  } from './lib/api';
  import {
    roleLabels,
    roles,
    type ContentCategoryGroup,
    type ContentItem,
    type ContentResponse,
    type DeepDungeonRow,
    type MountTable,
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

  const arrMountNames = ['Garuda', 'Ifrit', 'Titan', 'Ramuh', 'Leviathan', 'Shiva', 'Nightmare'];
  const heavenswardMountNames = ['Ravana', 'Bismarck', 'Thordan', 'Nidhogg', 'Sephirot', 'Sophia', 'Zurvan'];
  const stormbloodMountNames = ['Susano', 'Lakshmi', 'Shinryu', 'Byakko', 'Tsukuyomi', 'Suzaku', 'Seiryu', 'Rathalos'];
  const shadowbringersMountNames = ['Titania', 'Innocence', 'Hades', 'Ruby', 'WoL', 'Emerald', 'Diamond'];
  const endwalkerMountNames = ['Zodiark', 'Hydaelyn', 'Endsinger', 'Barbariccia', 'Rubicante', 'Golbez', 'Zeromus'];
  const dawntrailMountNames = ['Valigarmanda', 'Zoraal Ja', 'Sphene', 'Zelenia', 'Necron', 'Doomtrain', 'Enuo', 'Arkveld'];
  const arrMountRows = [
    'Astrid',
    'Avery',
    'Bari',
    'Corvus',
    'Eli',
    'Ellix',
    'Frosty',
    'Hanabi',
    'Kirby',
    'Krippy',
    'Lhei',
    'Luna',
    'Mateen',
    'Preto',
    'Ragna',
    'Raova',
    'Selene',
    'Selicia',
    'Shark',
    'Tiri',
    'Will',
    'Yen'
  ];

  function mountRow(name: string, values: boolean[]): MountTable['rows'][number] {
    return { name, values };
  }

  function fullMountRows(columns: string[], overrides: Record<string, boolean[]> = {}) {
    return arrMountRows.map((name) => mountRow(name, overrides[name] ?? columns.map(() => true)));
  }

  const defaultMountTables: Record<string, MountTable> = {
    arr: {
      columns: arrMountNames,
      rows: fullMountRows(arrMountNames, {
        Luna: [false, false, false, false, true, false, true]
      })
    },
    heavensward: {
      columns: heavenswardMountNames,
      rows: fullMountRows(heavenswardMountNames, {
        Luna: [false, false, false, false, false, false, true]
      })
    },
    stormblood: {
      columns: stormbloodMountNames,
      rows: fullMountRows(stormbloodMountNames, {
        Astrid: [true, true, true, true, true, true, true, false],
        Corvus: [true, true, true, true, true, true, true, false],
        Hanabi: [true, true, true, true, true, true, true, false],
        Krippy: [true, true, false, true, false, false, false, false],
        Luna: [true, true, true, true, true, false, true, false],
        Shark: [true, true, false, true, true, false, false, true]
      })
    },
    shadowbringers: {
      columns: shadowbringersMountNames,
      rows: fullMountRows(shadowbringersMountNames, {
        Bari: [true, true, false, true, true, true, true],
        Hanabi: [false, false, false, true, true, true, false],
        Krippy: [true, true, false, true, true, false, false],
        Raova: [true, true, true, false, true, false, false],
        Shark: [true, true, false, false, true, true, true],
        Will: [true, true, false, true, true, true, true]
      })
    },
    endwalker: {
      columns: endwalkerMountNames,
      rows: fullMountRows(endwalkerMountNames, {
        Astrid: [true, true, true, false, true, false, true],
        Avery: [true, true, true, false, true, false, false],
        Bari: [true, true, false, false, false, false, true],
        Frosty: [false, true, false, true, false, false, false],
        Hanabi: [false, true, false, false, false, false, false],
        Krippy: [false, false, false, false, false, false, false],
        Luna: [true, true, true, false, true, false, true],
        Mateen: [true, true, true, false, true, true, true],
        Preto: [true, true, true, true, true, true, false],
        Raova: [false, false, true, false, false, false, false],
        Selicia: [true, true, true, false, true, false, true],
        Shark: [false, false, false, false, false, false, true],
        Will: [true, true, true, false, false, false, true],
        Yen: [true, true, false, false, false, false, false]
      })
    },
    dawntrail: {
      columns: dawntrailMountNames,
      rows: fullMountRows(dawntrailMountNames, {
        Astrid: [false, true, false, false, false, false, false, false],
        Avery: [true, false, false, false, false, false, false, false],
        Bari: [false, true, false, false, false, false, false, false],
        Corvus: [false, false, false, false, false, false, false, false],
        Eli: [true, true, false, false, false, false, false, false],
        Ellix: [true, false, true, false, false, false, false, false],
        Frosty: [true, true, true, true, true, false, false, false],
        Hanabi: [true, false, false, false, false, false, false, false],
        Kirby: [true, false, false, false, false, false, false, false],
        Krippy: [false, false, false, false, false, false, false, false],
        Lhei: [true, true, true, true, true, true, true, false],
        Luna: [false, false, false, false, false, false, false, false],
        Mateen: [true, true, false, false, false, false, false, true],
        Preto: [false, false, false, false, false, false, false, false],
        Ragna: [true, true, true, true, true, true, true, false],
        Raova: [true, false, false, false, false, false, false, false],
        Selene: [true, true, true, false, false, false, false, false],
        Selicia: [true, false, false, true, false, false, false, false],
        Shark: [false, false, false, false, false, false, false, false],
        Tiri: [true, true, true, true, true, true, true, true],
        Will: [false, false, false, false, false, false, false, false],
        Yen: [false, false, false, false, false, false, false, false]
      })
    }
  };

  type UserContentStatus = {
    contentId: string;
    contentName: string;
    contentShortName: string | null;
    categoryName: string;
    expansionName: string | null;
    expansionShortName: string | null;
    role: SignupRole | undefined;
  };

  type ModalContentItem = ContentItem & {
    expansionName: string | null;
    expansionShortName: string | null;
    expansionOrder: number;
  };

  type ModalContentCategory = Omit<ContentCategoryGroup, 'contents'> & {
    contents: ModalContentItem[];
  };

  let mountTables: Record<string, MountTable> = structuredClone(defaultMountTables);
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
  let mountSaveMessage = '';
  let selectedUserName = '';
  let selectedUserContentStatuses: UserContentStatus[] = [];
  let userModalLoading = false;
  let userModalError = '';
  let fullModalCategories: ModalContentCategory[] | null = null;
  let activeView: 'content' | 'mounts' = 'content';
  let selectedMountExpansion = 'dawntrail';

  $: selectedMountTable = mountTables[selectedMountExpansion];

  onMount(async () => {
    await loadDeepDungeonRows();
    await loadMountTables();
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

  function sortDeepDungeonRows(rows: DeepDungeonRow[]) {
    return [...rows].sort((leftRow, rightRow) =>
      normalizeName(leftRow.name).localeCompare(normalizeName(rightRow.name))
    );
  }

  async function saveDeepDungeonRows(rows: DeepDungeonRow[], sortRows = true) {
    const nextRows = sortRows ? sortDeepDungeonRows(rows) : rows;

    deepDungeonRows = nextRows;
    cacheDeepDungeonRows(nextRows);
    deepDungeonSaveMessage = 'Saving sheet...';

    try {
      await saveDeepDungeonProgress(nextRows);
      deepDungeonSaveMessage = 'Sheet saved.';
    } catch (error) {
      deepDungeonSaveMessage =
        error instanceof Error ? error.message : 'Unable to save sheet to Supabase.';
    }
  }

  async function loadMountTables() {
    try {
      const loadedTables = await Promise.all(
        expansions.map(async (expansion) => {
          const fallbackTable = defaultMountTables[expansion.id];
          const loadedTable = await fetchMountProgress(expansion.id);

          if (isUsableMountTable(loadedTable)) {
            return [expansion.id, loadedTable] as const;
          }

          await saveMountProgress(expansion.id, fallbackTable.rows);
          return [expansion.id, fallbackTable] as const;
        })
      );

      mountTables = {
        ...mountTables,
        ...Object.fromEntries(loadedTables)
      };
      mountSaveMessage = '';
    } catch (error) {
      mountSaveMessage =
        error instanceof Error ? error.message : 'Using bundled mount spreadsheet data.';
    }
  }

  function isUsableMountTable(table: MountTable) {
    return (
      Array.isArray(table.columns) &&
      table.columns.length > 0 &&
      Array.isArray(table.rows) &&
      table.rows.length > 0 &&
      table.rows.every(
        (row) =>
          typeof row.name === 'string' &&
          Array.isArray(row.values) &&
          row.values.length === table.columns.length &&
          row.values.every((value) => typeof value === 'boolean')
      )
    );
  }

  function sortMountRows(rows: MountTable['rows']) {
    return [...rows].sort((leftRow, rightRow) =>
      normalizeName(leftRow.name).localeCompare(normalizeName(rightRow.name))
    );
  }

  async function saveSelectedMountTable(rows = mountTables[selectedMountExpansion].rows, sortRows = true) {
    const nextRows = sortRows ? sortMountRows(rows) : rows;

    mountTables = {
      ...mountTables,
      [selectedMountExpansion]: {
        ...mountTables[selectedMountExpansion],
        rows: nextRows
      }
    };
    mountSaveMessage = 'Saving sheet...';

    try {
      await saveMountProgress(selectedMountExpansion, nextRows);
      mountSaveMessage = 'Sheet saved.';
    } catch (error) {
      mountSaveMessage =
        error instanceof Error ? error.message : 'Unable to save mount progress.';
    }
  }

  function updateDeepDungeonName(rowIndex: number, value: string) {
    deepDungeonRows = deepDungeonRows.map((row, index) =>
      index === rowIndex ? { ...row, name: value } : row
    );
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

  function addMountUser() {
    const table = mountTables[selectedMountExpansion];
    const rows = [
      ...table.rows,
      {
        name: '',
        values: table.columns.map(() => false)
      }
    ];

    void saveSelectedMountTable(rows, false);
  }

  function updateMountUserName(rowIndex: number, value: string) {
    const table = mountTables[selectedMountExpansion];
    const rows = table.rows.map((row, index) =>
      index === rowIndex ? { ...row, name: value } : row
    );

    mountTables = {
      ...mountTables,
      [selectedMountExpansion]: {
        ...table,
        rows
      }
    };
  }

  function toggleMountValue(rowIndex: number, valueIndex: number) {
    const table = mountTables[selectedMountExpansion];
    const rows = table.rows.map((row, index) =>
      index === rowIndex
        ? {
            ...row,
            values: row.values.map((value, currentValueIndex) =>
              currentValueIndex === valueIndex ? !value : value
            )
          }
        : row
    );

    void saveSelectedMountTable(rows);
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
      fullModalCategories = null;
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

  async function openUserModal(name: string) {
    selectedUserName = name;
    selectedUserContentStatuses = [];
    userModalLoading = true;
    userModalError = '';

    try {
      const categories = await loadFullModalCategories();
      selectedUserContentStatuses = getUserLearnerOrMissingContent(name, categories);
    } catch (error) {
      userModalError =
        error instanceof Error ? error.message : 'Unable to load all content for this character.';
    } finally {
      userModalLoading = false;
    }
  }

  function closeUserModal() {
    selectedUserName = '';
    selectedUserContentStatuses = [];
    userModalLoading = false;
    userModalError = '';
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

  async function loadFullModalCategories() {
    if (fullModalCategories) {
      return fullModalCategories;
    }

    const [ultimates, extremeCategories, savageCategories] = await Promise.all([
      fetchUltimates(),
      Promise.all(expansions.map((expansion) => fetchExtremes(expansion.id))),
      Promise.all(expansions.map((expansion) => fetchSavages(expansion.id)))
    ]);

    fullModalCategories = [
      annotateModalCategory(ultimates, null),
      mergeModalExpansionCategories(extremeCategories),
      mergeModalExpansionCategories(savageCategories)
    ];

    return fullModalCategories;
  }

  function annotateModalCategory(
    category: ContentCategoryGroup,
    expansion: (typeof expansions)[number] | null
  ): ModalContentCategory {
    return {
      ...category,
      contents: category.contents.map((content) => ({
        ...content,
        expansionName: expansion?.name ?? null,
        expansionShortName: expansion?.shortName ?? null,
        expansionOrder: expansion
          ? expansions.findIndex((currentExpansion) => currentExpansion.id === expansion.id)
          : -1
      }))
    };
  }

  function mergeModalExpansionCategories(categories: ContentCategoryGroup[]): ModalContentCategory {
    const [firstCategory] = categories;

    return {
      ...firstCategory,
      contents: categories
        .flatMap((category, index) => annotateModalCategory(category, expansions[index]).contents)
        .sort((leftContent, rightContent) => {
          if (leftContent.expansionOrder !== rightContent.expansionOrder) {
            return leftContent.expansionOrder - rightContent.expansionOrder;
          }

          return leftContent.sortOrder - rightContent.sortOrder;
        })
    };
  }

  function getUserLearnerOrMissingContent(name: string, categories: ModalContentCategory[]) {
    const normalizedName = normalizeName(name);

    if (!normalizedName) {
      return [];
    }

    const statuses: UserContentStatus[] = [];

    for (const category of categories) {
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
            expansionName: content.expansionName,
            expansionShortName: content.expansionShortName,
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
  <header class="site-header">
    <h1>Comfy Content <span>Tracker</span></h1>
  </header>

  <nav class="view-switcher" aria-label="Content view">
    <button
      type="button"
      class:active={activeView === 'content'}
      aria-pressed={activeView === 'content'}
      on:click={() => (activeView = 'content')}
    >
      Content Board
    </button>
    <button
      type="button"
      class:active={activeView === 'mounts'}
      aria-pressed={activeView === 'mounts'}
      on:click={() => (activeView = 'mounts')}
    >
      Mounts
    </button>
  </nav>

  {#if activeView === 'content'}
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
  {/if}

  {#if loading}
    <section class="state-panel">Loading content...</section>
  {:else if globalError}
    <section class="state-panel error">
      <p>{globalError}</p>
      <button type="button" on:click={loadContent}>Try again</button>
    </section>
  {:else if data}
    {#key activeView}
      <div class="view-transition-panel">
        {#if activeView === 'content'}
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
                      on:blur={() => saveDeepDungeonRows(deepDungeonRows)}
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
        {:else}
      <section class="mounts-panel" aria-label="Mount related content">
        <div class="section-label mounts">
          <span>Mount Related Content</span>
        </div>
        <div class="category-heading">
          <div class="expansion-tabs" role="tablist" aria-label="Mount expansion">
            {#each expansions as expansion}
              <button
                type="button"
                role="tab"
                aria-selected={selectedMountExpansion === expansion.id}
                class:active={selectedMountExpansion === expansion.id}
                title={expansion.name}
                on:click={() => (selectedMountExpansion = expansion.id)}
              >
                {expansion.name}
              </button>
            {/each}
          </div>
        </div>
        <div class="deep-table-panel mounts-table-panel">
          <div class="deep-table-scroll">
            <table class="deep-table mounts-table">
              <thead>
                <tr>
                  <th scope="col">Character</th>
                  {#each selectedMountTable.columns as column}
                    <th scope="col">{column}</th>
                  {/each}
                </tr>
              </thead>
              <tbody>
                {#each selectedMountTable.rows as row, rowIndex}
                  <tr>
                    <th scope="row">
                      <input
                        class="deep-name-input"
                        value={row.name}
                        aria-label="Character name"
                        maxlength="64"
                        on:input={(event) => updateMountUserName(rowIndex, event.currentTarget.value)}
                        on:blur={() => saveSelectedMountTable()}
                      />
                    </th>
                    {#each row.values as value, valueIndex}
                      <td class:cleared={value} class:missing={!value}>
                        <button
                          class="mount-status-btn"
                          class:acquired={value}
                          class:missing={!value}
                          type="button"
                          aria-pressed={value}
                          aria-label={`${row.name || 'Unnamed character'} ${selectedMountTable.columns[valueIndex]} ${value ? 'acquired' : 'missing'}`}
                          on:click={() => toggleMountValue(rowIndex, valueIndex)}
                        >
                          {#if value}
                            ✓
                          {/if}
                        </button>
                      </td>
                    {/each}
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        </div>
        <div class="deep-table-actions">
          <button class="deep-add-btn" type="button" on:click={addMountUser}>
            Add User
          </button>
        </div>
        {#if mountSaveMessage}
          <p class="deep-save-message">{mountSaveMessage}</p>
        {/if}
      </section>
        {/if}
      </div>
    {/key}
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
          {#if userModalLoading}
            <p class="user-modal-empty">Loading all content...</p>
          {:else if userModalError}
            <p class="user-modal-empty error">{userModalError}</p>
          {:else if selectedUserContentStatuses.length}
            <ul class="user-content-list">
              {#each selectedUserContentStatuses as status}
                <li class:learner-missing={!status.role}>
                  <div>
                    <strong>{status.contentName}</strong>
                    {#if status.contentShortName}
                      <span>{status.contentShortName}</span>
                    {/if}
                    <small>
                      {status.expansionShortName
                        ? `${status.categoryName} · ${status.expansionShortName}`
                        : status.categoryName}
                    </small>
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
