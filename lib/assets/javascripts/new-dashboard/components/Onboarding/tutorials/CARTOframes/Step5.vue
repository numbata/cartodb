<template>
  <div class="u-width--100 u-pr--10 u-pl--10">
    <StepTitle :title="$t(`Wizards.cartoframes.sections.summary`)">
      <template slot="icon">
          <img svg-inline src="../../../../assets/icons/onboarding/summary.svg"/>
      </template>
    </StepTitle>
    <p v-html="$t(`Wizards.cartoframes.step5.summary`)" class="text is-body u-mb--64"></p>

    <StepTitle :title="$t(`Wizards.cartoframes.sections.howto`)">
      <template slot="icon">
          <img svg-inline src="../../../../assets/icons/onboarding/howto.svg"/>
      </template>
    </StepTitle>
    <ol class="u-list__style--decimal u-list__position--inside">
      <li>
        <p v-html="$t(`Wizards.cartoframes.step5.howto.instruction1`)" class="text is-caption u-inline"></p>
        <Jupyter>
          <JupyterBlock :isInput="true">
            <CodeBlock :code="codeBlock1" language="python" :lineNumbers="false" :theme="'default'"></CodeBlock>
          </JupyterBlock>
          <JupyterBlock :isInput="false">
            <Table1></Table1>
          </JupyterBlock>
        </Jupyter>
      </li>
    </ol>


  </div>
</template>
<script>
import CodeBlock from 'new-dashboard/components/Code/CodeBlock.vue';
import StepTitle from 'new-dashboard/components/Onboarding/components/StepTitle.vue';
import Jupyter from 'new-dashboard/components/Code/Jupyter.vue';
import JupyterBlock from 'new-dashboard/components/Code/JupyterBlock.vue';
import Table1 from 'new-dashboard/components/Onboarding/tutorials/CARTOframes/Table5_1.vue';

export default {
  name: 'Step5',
  stepName: 'Read one dataset',
  components: {
    CodeBlock,
    StepTitle,
    Jupyter,
    JupyterBlock,
    Table1
  },
  data () {
    return {
      codeBlock1
    };
  }
};

const codeBlock1 =
`df = cc.read('world_ports')
df.head()`;
</script>
